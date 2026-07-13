local process = require("std.process")
local logger = require("std.logger")

---@class kbplugin.mdtyp.UserConfig
---@field timeout? integer  curl timeout in seconds (default 10)
---@field pattern? string   regex pattern to extract title from HTML

---@class kbplugin.mdtyp.Health
---@field enabled     boolean
---@field curl_found  boolean
---@field timeout     integer

---@class kbplugin.mdtyp.TableSpec
---@field cols     integer
---@field rows     integer
---@field headers  string[]
---@field named    boolean  true when headers came from `Name | Name xN` syntax

local M = {}

local Log = logger.new({
  path = vim.fn.stdpath("state") .. "/kbplugin/mdtyp.log",
})

local Config = {
  timeout = 10,
  --- Default: extract content between <title> and </title>, case-insensitive
  pattern = "<title[^>]*>(.-)</title>",
}

---@param opts? kbplugin.mdtyp.UserConfig
function M.setup(opts)
  opts = opts or {}
  if opts.timeout then
    Config.timeout = opts.timeout
  end
  if opts.pattern then
    Config.pattern = opts.pattern
  end
  M._register_commands()
end

--- Build a clipboard-aware user command.
---@param name     string   command name
---@param fmt      fun(title: string, url: string): string  link formatter
---@param desc     string   help text
local function register_link_command(name, fmt, desc)
  vim.api.nvim_create_user_command(name, function (cmd)
    local url = cmd.fargs[1]
    -- No arg → read from clipboard
    if not url or url == "" then
      url = vim.fn.getreg("+"):match("^%s*(.-)%s*$")
    end
    if not url or url == "" then
      vim.notify(
        name .. ": no URL provided and clipboard is empty",
        vim.log.levels.ERROR
      )
      return
    end
    -- Basic URL validation
    if not url:match("^https?://") then
      vim.notify(
        name .. ": doesn't look like a URL: " .. url,
        vim.log.levels.WARN
      )
      return
    end
    M._fetch_and_insert(url, fmt, name)
  end, {
    nargs = "?",
    desc = desc,
  })
end

--- Parse table syntax into columns, rows, and header labels.
--- Supports:
---   `2x2`                 → 2 cols, 2 rows, headers header1..headerN
---   `File | Purpose x4`   → named headers, 4 rows
---@param syntax string
---@return kbplugin.mdtyp.TableSpec? spec
---@return string? err
function M._parse_table_syntax(syntax)
  syntax = vim.trim(syntax or "")
  if syntax == "" then
    return nil, "empty syntax (e.g. 2x2 or File | Purpose x4)"
  end

  local dim_cols, dim_rows = syntax:match("^(%d+)%s*[xX]%s*(%d+)$")
  if dim_cols and dim_rows then
    local cols = tonumber(dim_cols) --[[@as integer]]
    local rows = tonumber(dim_rows) --[[@as integer]]
    if cols < 1 or rows < 1 then
      return nil, "columns and rows must be >= 1"
    end
    local headers = {}
    for c = 1, cols do
      headers[c] = "header" .. c
    end
    return { cols = cols, rows = rows, headers = headers, named = false }
  end

  local header_part, row_part = syntax:match("^(.-)%s*[xX]%s*(%d+)$")
  if not header_part or not row_part then
    return nil, "invalid syntax (e.g. 2x2 or File | Purpose x4)"
  end

  local rows = tonumber(row_part) --[[@as integer]]
  if rows < 1 then
    return nil, "row count must be >= 1"
  end

  local headers = {}
  for part in (header_part .. "|"):gmatch("(.-)|") do
    local h = vim.trim(part)
    if h ~= "" then
      headers[#headers + 1] = h
    end
  end

  if #headers < 1 then
    return nil, "need at least one header name"
  end

  return { cols = #headers, rows = rows, headers = headers, named = true }
end

--- Cell placeholder: dimension form uses RxC; named headers use NamexR.
---@param header string
---@param row    integer
---@param col    integer
---@param named  boolean
---@return string
local function cell_placeholder(header, row, col, named)
  if named then
    return header .. "x" .. row
  end
  return row .. "x" .. col
end

---@param spec kbplugin.mdtyp.TableSpec
---@return string[]
function M._format_markdown_table(spec)
  local named = spec.named

  local widths = {}
  for c = 1, spec.cols do
    widths[c] = #spec.headers[c]
  end
  local cells = {}
  for r = 1, spec.rows do
    cells[r] = {}
    for c = 1, spec.cols do
      local cell = cell_placeholder(spec.headers[c], r, c, named)
      cells[r][c] = cell
      if #cell > widths[c] then
        widths[c] = #cell
      end
    end
  end

  local function pad(text, width)
    return text .. string.rep(" ", width - #text)
  end

  local lines = {}
  local header_cells = {}
  local sep_cells = {}
  for c = 1, spec.cols do
    header_cells[c] = pad(spec.headers[c], widths[c])
    sep_cells[c] = string.rep("-", widths[c])
  end
  lines[#lines + 1] = "| " .. table.concat(header_cells, " | ") .. " |"
  lines[#lines + 1] = "| " .. table.concat(sep_cells, " | ") .. " |"
  for r = 1, spec.rows do
    local row_cells = {}
    for c = 1, spec.cols do
      row_cells[c] = pad(cells[r][c], widths[c])
    end
    lines[#lines + 1] = "| " .. table.concat(row_cells, " | ") .. " |"
  end
  return lines
end

---@param spec kbplugin.mdtyp.TableSpec
---@return string[]
function M._format_typst_table(spec)
  local named = spec.named

  local lines = {
    "#table(",
    string.format("  columns: (%d * (auto,)),", spec.cols),
  }

  local header_cells = {}
  for c = 1, spec.cols do
    header_cells[c] = "[" .. spec.headers[c] .. "]"
  end
  lines[#lines + 1] = "  table.header(" .. table.concat(header_cells, ", ") .. "),"

  for r = 1, spec.rows do
    local row_cells = {}
    for c = 1, spec.cols do
      row_cells[c] = "[" .. cell_placeholder(spec.headers[c], r, c, named) .. "]"
    end
    local suffix = r < spec.rows and "," or ""
    lines[#lines + 1] = "  " .. table.concat(row_cells, ", ") .. suffix
  end
  lines[#lines + 1] = ")"
  return lines
end

---@param lines string[]
local function insert_lines_below_cursor(lines)
  local buf = vim.api.nvim_get_current_buf()
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.api.nvim_buf_set_lines(buf, row, row, false, lines)
  vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
end

---@param name     string
---@param formatter fun(spec: kbplugin.mdtyp.TableSpec): string[]
---@param desc     string
local function register_table_command(name, formatter, desc)
  vim.api.nvim_create_user_command(name, function (cmd)
    local spec, err = M._parse_table_syntax(cmd.args)
    if not spec then
      vim.notify(name .. ": " .. (err or "invalid syntax"), vim.log.levels.ERROR)
      return
    end
    local lines = formatter(spec)
    insert_lines_below_cursor(lines)
    Log:info("inserted table", {
      command = name,
      cols = spec.cols,
      rows = spec.rows,
      headers = spec.headers,
    })
  end, {
    nargs = "+",
    desc = desc,
  })
end

function M._register_commands()
  register_link_command("Mdlink", function (title, url)
    return string.format("[%s](%s)", title, url)
  end, "Fetch page title, insert as Markdown link (reads clipboard if no arg)")

  register_link_command("Typlink", function (title, url)
    return string.format('#link("%s")[%s]', url, title)
  end, "Fetch page title, insert as Typst link (reads clipboard if no arg)")

  register_table_command(
    "Mdtable",
    M._format_markdown_table,
    "Insert a Markdown table (2x2 or File | Purpose x4)"
  )

  register_table_command(
    "Typtable",
    M._format_typst_table,
    "Insert a Typst table (2x2 or File | Purpose x4)"
  )
end

--- Fetch the <title> from a URL and insert a formatted link at the cursor.
---@param url    string
---@param fmt    fun(title: string, url: string): string
---@param label  string  command name for notifications
function M._fetch_and_insert(url, fmt, label)
  local argv = {
    "curl", "-sL",
    "--max-time", tostring(Config.timeout),
    "-H", "User-Agent: Mozilla/5.0 (compatible; kbplugin/mdtyp)",
    url,
  }

  Log:info("fetching title", { url = url, command = label })

  -- Snapshot cursor position and buffer BEFORE the async fetch
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local cursor_buf = vim.api.nvim_get_current_buf()

  ---@diagnostic disable-next-line: param-type-mismatch
  local cmd = process.make(argv[1], vim.list_slice(argv, 2))
  process.execute_text(cmd, function (err, result)
    vim.schedule(function ()
      -- Bail if user switched buffers during the fetch
      if vim.api.nvim_get_current_buf() ~= cursor_buf then
        Log:warn("buffer changed, skipping insert", { url = url })
        return
      end

      if err or not result then
        vim.notify(
          label .. ": fetch failed: " .. tostring(err or "no result"),
          vim.log.levels.ERROR
        )
        Log:error("fetch failed", { url = url, err = err })
        return
      end

      if result.code ~= 0 then
        vim.notify(
          label .. ": curl exited " .. result.code,
          vim.log.levels.ERROR
        )
        Log:error("curl error", {
          url = url,
          code = result.code,
          stderr = result.stderr,
        })
        return
      end

      local title = result.stdout:match(Config.pattern)
      if not title then
        vim.notify(
          label .. ": no <title> found, using URL as label",
          vim.log.levels.WARN
        )
        title = url
      else
        -- Strip leading/trailing whitespace and decode common HTML entities
        title = title:gsub("^%s+", ""):gsub("%s+$", "")
        title = title:gsub("&amp;", "&")
        title = title:gsub("&lt;", "<")
        title = title:gsub("&gt;", ">")
        title = title:gsub("&quot;", '"')
        title = title:gsub("&#39;", "'")
      end

      local link = fmt(title, url)

      -- Insert at the snapshotted cursor position
      local row = cursor_pos[1]
      local col = cursor_pos[2]
      local lines = vim.api.nvim_buf_get_lines(cursor_buf, row - 1, row, false)
      if #lines == 0 then
        -- Line was deleted — append at end of saved row
        vim.api.nvim_buf_set_lines(cursor_buf, row - 1, row - 1, false, { link })
      else
        local line = lines[1]
        local before = line:sub(1, col)
        local after = line:sub(col + 1)
        vim.api.nvim_buf_set_lines(cursor_buf, row - 1, row, false, {
          before .. link .. after,
        })
      end

      -- Place cursor after the inserted link
      vim.api.nvim_win_set_cursor(0, { row, col + #link })

      Log:info("inserted link", { title = title, url = url, command = label })
    end)
  end)
end

---@return kbplugin.mdtyp.Health
function M.health()
  return {
    enabled = true,
    curl_found = vim.fn.executable("curl") == 1,
    timeout = Config.timeout,
  }
end

---@return std.logger.Instance
function M.logger()
  return Log
end

return M
