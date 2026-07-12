local M = {}
local H = {}

---@param uri string
---@return integer
local function uri_to_bufnr(uri)
  return vim.uri_to_bufnr(uri)
end

---@param bufnr integer
---@return integer?
local function tab_with_bufnr(bufnr)
  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
      if vim.api.nvim_win_get_buf(win) == bufnr then
        return vim.api.nvim_tabpage_get_number(tabpage)
      end
    end
  end
  return nil
end

---@param location lsp.Location|lsp.LocationLink
local function jump_to_definition_in_tab(location)
  local uri = location.uri or location.targetUri
  if uri == nil then
    return
  end

  local target_bufnr = uri_to_bufnr(uri)
  local tabnr = tab_with_bufnr(target_bufnr)
  if tabnr ~= nil then
    vim.cmd.tabnext(tabnr)
  else
    vim.cmd.tabedit(vim.uri_to_fname(uri))
  end

  vim.lsp.util.show_document(location, "utf-8", { focus = true })
end

---@param result lsp.Location|lsp.Location[]|lsp.LocationLink[]|nil
local function handle_definition_tab_result(result)
  if result == nil or vim.tbl_isempty(result) then
    vim.notify("No definition found", vim.log.levels.INFO)
    return
  end

  if vim.islist(result) then
    jump_to_definition_in_tab(result[1])
    return
  end

  jump_to_definition_in_tab(result)
end

local function lsp_definition_tab()
  local params = vim.lsp.util.make_position_params(0, "utf-8")
  vim.lsp.buf_request(0, "textDocument/definition", params, function (err, result)
    if err ~= nil then
      vim.notify(err.message, vim.log.levels.ERROR)
      return
    end

    vim.schedule(function ()
      handle_definition_tab_result(result)
    end)
  end)
end

local function visual_lines()
  local start_line = vim.fn.line(".")
  local end_line = start_line

  if vim.fn.mode():match("[vV\022]") then
    start_line = vim.fn.line("v")
    end_line = vim.fn.line(".")
  end

  if start_line > end_line then
    start_line, end_line = end_line, start_line
  end

  return start_line, end_line
end

local function file_path(absolute)
  local buf = vim.fn.resolve(vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":p"))
  if absolute then return buf end
  return vim.fn.fnamemodify(buf, ":~:.")
end

function H.yank()
  vim.keymap.set({ "n", "v" }, "<leader>yy", '"+y', {
    desc = "Copy to System Clipboard"
  })
  vim.keymap.set({ "n", "v" }, "<leader>p", '"+p', {
    desc = "Paste from System Clipboard"
  })
  vim.keymap.set({ "n", "x" }, "<leader>yl", function()
    local s, e = visual_lines()
    vim.fn.setreg("+", string.format("%s:%d:%d", file_path(false), s, e))
  end, {
    desc = "Copy File Location (relative)"
  })
  vim.keymap.set({ "n", "x" }, "<leader>yL", function()
    local s, e = visual_lines()
    vim.fn.setreg("+", string.format("%s:%d:%d", file_path(true), s, e))
  end, {
    desc = "Copy File Location (absolute)"
  })
  vim.keymap.set({ "n", "x" }, "<leader>yc", function()
    local s, e = visual_lines()
    local ctx = H.treesitter_context()
    vim.fn.setreg("+", string.format("%s:%d:%d%s", file_path(false), s, e, ctx))
  end, {
    desc = "Copy File Location with Context (relative)"
  })
  vim.keymap.set({ "n", "x" }, "<leader>yC", function()
    local s, e = visual_lines()
    local ctx = H.treesitter_context()
    vim.fn.setreg("+", string.format("%s:%d:%d%s", file_path(true), s, e, ctx))
  end, {
    desc = "Copy File Location with Context (absolute)"
  })
  vim.keymap.set({ "n", "x" }, "<leader>ys", function()
    local s, e = visual_lines()
    local path = file_path(false)
    local ctx = H.treesitter_context()
    local ft = vim.bo.filetype
    local content = table.concat(vim.api.nvim_buf_get_lines(0, s - 1, e, false), "\n")
    vim.fn.setreg("+", string.format("@%s:%d:%d%s\n```%s\n%s\n```\n", path, s, e, ctx, ft, content))
  end, {
    desc = "Copy as Fenced Snippet (relative path)"
  })
  vim.keymap.set({ "n", "x" }, "<leader>yS", function()
    local s, e = visual_lines()
    local path = file_path(true)
    local ctx = H.treesitter_context()
    local ft = vim.bo.filetype
    local content = table.concat(vim.api.nvim_buf_get_lines(0, s - 1, e, false), "\n")
    vim.fn.setreg("+", string.format("@%s:%d:%d%s\n```%s\n%s\n```\n", path, s, e, ctx, ft, content))
  end, {
    desc = "Copy as Fenced Snippet (absolute path)"
  })
  vim.keymap.set(
    { "n", "x" }, "<leader>yg",
    function()
      local git_root = vim.fn.system("git rev-parse --show-toplevel"):gsub("%s+$", "")
      if vim.v.shell_error ~= 0 then
        return vim.notify("Not in a git repo", vim.log.levels.ERROR)
      end

      local file = vim.fn.expand("%:p")
      local rel = file:sub(#git_root + 2)

      local remote = vim.fn.system("git remote get-url origin"):gsub("%s+$", "")
      local repo = remote:match("github%.com[:/](.+%.git)$")
        or remote:match("github%.com[:/](.+)$")
      if not repo then
        return vim.notify("No GitHub remote", vim.log.levels.ERROR)
      end
      repo = repo:gsub("%.git$", "")

      local ref = vim.fn.system("git describe --exact-match --tags HEAD 2>/dev/null"):gsub("%s+$", "")
      if vim.v.shell_error ~= 0 then
        ref = vim.fn.system("git symbolic-ref --short HEAD 2>/dev/null"):gsub("%s+$", "")
        if vim.v.shell_error ~= 0 then
          ref = vim.fn.system("git rev-parse HEAD"):gsub("%s+$", "")
        end
      end

      local s, e = visual_lines()
      local anchor = ""
      if s == e then
        anchor = "#L" .. s
      else
        anchor = "#L" .. s .. "-L" .. e
      end

      local url = string.format("https://github.com/%s/blob/%s/%s%s", repo, ref, rel, anchor)
      vim.fn.setreg("+", url)
      vim.notify("Copied: " .. url)
    end,
    { desc = "Copy GitHub URL" }
  )
end

function H.file_type()
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "qf",
    callback = function (args)
      vim.keymap.set("n", "<Esc>", "<cmd>cclose<cr>", {
        buffer = args.buf,
        silent = true,
        nowait = true
      })
      vim.keymap.set(
        "n", "<CR>",
        function ()
          local win = vim.api.nvim_get_current_win()
          vim.cmd.cc({ count = vim.fn.line(".") })
          vim.schedule(function ()
            pcall(vim.api.nvim_win_close, win, true)
          end)
        end,
        {
          buffer = args.buf,
          silent = true,
          nowait = true
        }
      )
    end
  })

  vim.api.nvim_create_autocmd("FileType", {
    pattern = "typst",
    callback = function (args)
      local opts = { buffer = args.buf, silent = true }
      vim.keymap.set(
        "n", "<leader>dp", "<cmd>TypstPreview<cr>",
        vim.tbl_extend("force", opts, {
          desc = "[P]review"
        })
      )
      vim.keymap.set(
        "n", "<leader>dP", "<cmd>TypstPreviewStop<cr>",
        vim.tbl_extend("force", opts, {
          desc = "Stop [P]review"
        })
      )
    end
  })
end
local scope_types = {
  class_definition = true, class_declaration = true, class = true,
  function_definition = true, function_declaration = true,
  method_definition = true, method_declaration = true, method = true,
  impl_item = true, struct_item = true, enum_item = true,
  trait_item = true, interface_declaration = true,
  module = true, module_declaration = true, mod_item = true,
  fn = true, function_item = true,
}

function H.treesitter_context()
  local bufnr = 0
  local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
  if not ok or not parser then return " <none>" end
  parser:parse()
  local node = vim.treesitter.get_node({ bufnr = bufnr })
  if not node then return " <none>" end

  local parts = {}
  while node do
    if scope_types[node:type()] then
      -- Try "name" field first, fallback to "type" (e.g. impl_item in Rust)
      local name_fields = node:field("name")
      if #name_fields == 0 then
        name_fields = node:field("type")
      end
      if #name_fields > 0 then
        local text = vim.treesitter.get_node_text(name_fields[1], 0)
        if text and text ~= "" then
          table.insert(parts, 1, text)
        end
      end
    end
    node = node:parent()
  end

  if #parts == 0 then return " <none>" end
  if #parts == 1 then return " ::" .. parts[1] end
  local inner = table.remove(parts)
  return " ::" .. table.concat(parts, "::") .. ">" .. inner
end

function M.setup()
  H.file_type()
  H.yank()

  vim.keymap.set("n", "<ESC>", "<CMD>nohlsearch<CR>")
  vim.keymap.set("t", "<ESC><ESC>", "<C-\\><C-n>", {
    desc = "Exit Terminal Mode"
  })

  vim.keymap.set("n", "<leader>R", function ()
    require("kbplugin.restart").restart()
  end, { desc = "Restart" }
  )
  vim.keymap.set("n", "<leader>r", function ()
    vim.cmd.edit({ bang = true })
  end, { desc = "Reload Buffer" }
  )
  vim.keymap.set("n", "<leader>iu", function ()
    local uuid

    if vim.fn.executable("uuidgen") == 1 then
      uuid = (vim.fn.system("uuidgen") or ""):gsub("%s+$", "")
    end

    if not uuid or uuid == "" then
      math.randomseed(vim.uv.hrtime())
      local template = "xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx"
      uuid = template:gsub("[xy]", function (c)
        local v = (c == "x") and math.random(0, 15) or math.random(8, 11)
        return string.format("%x", v)
      end)
    end

    vim.api.nvim_put({ uuid }, "c", false, true)
  end, { desc = "[U]UID" }
  )

  vim.keymap.set("n", "<leader>itd", function ()
    vim.api.nvim_put({ os.date("%Y-%m-%d") }, "c", false, true)
  end, { desc = "[D]ay" }
  )

  vim.keymap.set("n", "<leader>itt", function ()
    vim.api.nvim_put({ os.date("%H:%M") }, "c", false, true)
  end, { desc = "[T]ime" }
  )

  vim.keymap.set("n", "<leader>itn", function ()
    vim.api.nvim_put({ os.date("%Y-%m-%d %H:%M:%S") }, "c", false, true)
  end, { desc = "[N]ow" }
  )

  vim.keymap.set("n", "<leader>itu", function ()
    vim.api.nvim_put({ os.date("!%Y-%m-%dT%H:%M:%SZ") }, "c", false, true)
  end, { desc = "[U]TC" }
  )

  vim.keymap.set("n", "<leader>ith", function ()
    local ts = os.date("%Y-%m-%dT%H:%M:%S%z"):gsub("([+-]%d%d)(%d%d)$", "%1:%2")
    vim.api.nvim_put({ ts }, "c", false, true)
  end, { desc = "[H]ere RFC 3339" }
  )

  vim.keymap.set("x", "<leader>itc", function ()
    require("kbinit.keymap.time").convert_visual()
  end, { desc = "[C]onvert Time" }
  )
end

---@param bufnr        integer
---@param client       vim.lsp.Client
---@param capabilities lsp.ServerCapabilities
function M.on_lsp_attach(bufnr, _client, capabilities)
  if capabilities.definitionProvider then
    pcall(vim.keymap.del, "n", "gd", { buffer = bufnr })

    vim.keymap.set("n", "gdd", vim.lsp.buf.definition, {
      buffer = bufnr,
      desc = "[D]efinition"
    })

    vim.keymap.set("n", "gdt", lsp_definition_tab, {
      buffer = bufnr,
      desc = "[D]efinition in [T]ab"
    })

    vim.keymap.set("n", "gds", function ()
      vim.cmd.split()
      vim.lsp.buf.definition()
    end, {
      buffer = bufnr,
      desc = "[D]efinition in [S]plit"
    })

    vim.keymap.set("n", "gdv", function ()
      vim.cmd.vsplit()
      vim.lsp.buf.definition()
    end, {
      buffer = bufnr,
      desc = "[D]efinition in [V]ertical Split"
    })

    vim.keymap.set("n", "grd", vim.lsp.buf.definition, {
      buffer = bufnr,
      desc = "[D]efinition"
    })
  end

  if capabilities.hoverProvider then
    vim.keymap.set("n", "K", vim.lsp.buf.hover, {
      buffer = bufnr,
      desc = "[LSP] Hover Documentation"
    })
  end
end

return M
