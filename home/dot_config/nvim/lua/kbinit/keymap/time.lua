local snacks = require("snacks")

local M = {}

---@return {start_lnum: integer, start_col: integer, end_lnum: integer, end_col: integer, text: string}|nil
local function visual_selection()
  local s = vim.api.nvim_buf_get_mark(0, "<")
  local e = vim.api.nvim_buf_get_mark(0, ">")
  if not s or not e then
    return nil
  end

  local start_lnum, start_col = s[1], s[2]
  local end_lnum, end_col = e[1], e[2]
  if start_lnum == 0 or end_lnum == 0 then
    return nil
  end

  -- Make range forward
  if end_lnum < start_lnum or (end_lnum == start_lnum and end_col < start_col) then
    start_lnum, end_lnum = end_lnum, start_lnum
    start_col, end_col = end_col, start_col
  end

  local lines = vim.api.nvim_buf_get_text(0, start_lnum - 1, start_col, end_lnum - 1, end_col + 1, {})
  return {
    start_lnum = start_lnum,
    start_col = start_col,
    end_lnum = end_lnum,
    end_col = end_col,
    text = table.concat(lines, "\n"),
  }
end

local function set_range_text(range, replacement)
  local lines = vim.split(replacement, "\n", { plain = true })
  vim.api.nvim_buf_set_text(
    0,
    range.start_lnum - 1,
    range.start_col,
    range.end_lnum - 1,
    range.end_col + 1,
    lines
  )
end

local function tz_offset_colon(date_fmt, epoch)
  return (os.date(date_fmt, epoch):gsub("([+-]%d%d)(%d%d)$", "%1:%2"))
end

---@param s string
---@return {kind:"time"|"rfc3339", hour:integer, min:integer, sec:integer, year?:integer, month?:integer, day?:integer, tz?:string}|nil
local function parse_input(s)
  s = vim.trim(s)

  do
    local hh, mm, ss = s:match("^(%d%d):(%d%d):(%d%d)$")
    if hh and mm and ss then
      return { kind = "time", hour = tonumber(hh), min = tonumber(mm), sec = tonumber(ss) }
    end
  end
  do
    local hh, mm = s:match("^(%d%d):(%d%d)$")
    if hh and mm then
      return { kind = "time", hour = tonumber(hh), min = tonumber(mm), sec = 0 }
    end
  end

  do
    local y, mo, d, hh, mm, ss, _z = s:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)([Zz])$")
    if y then
      return {
        kind = "rfc3339",
        year = tonumber(y),
        month = tonumber(mo),
        day = tonumber(d),
        hour = tonumber(hh),
        min = tonumber(mm),
        sec = tonumber(ss),
        tz = "Z",
      }
    end
  end

  do
    local y, mo, d, hh, mm, ss, sign, th, tm = s:match(
      "^(%d%d%d%d)%-(%d%d)%-(%d%d)T(%d%d):(%d%d):(%d%d)([+-])(%d%d):?(%d%d)$"
    )
    if y then
      return {
        kind = "rfc3339",
        year = tonumber(y),
        month = tonumber(mo),
        day = tonumber(d),
        hour = tonumber(hh),
        min = tonumber(mm),
        sec = tonumber(ss),
        tz = sign .. th .. ":" .. tm,
      }
    end
  end

  return nil
end

local function time12(h, m, s, with_seconds)
  local ap = (h >= 12) and "PM" or "AM"
  local hh = h % 12
  if hh == 0 then hh = 12 end
  if with_seconds then
    return string.format("%d:%02d:%02d%s", hh, m, s, ap)
  end
  return string.format("%d:%02d%s", hh, m, ap)
end

---@param parsed table
---@return integer epoch_local
local function epoch_from_local_date(parsed)
  local today = os.date("*t")
  return os.time({
    year = today.year,
    month = today.month,
    day = today.day,
    hour = parsed.hour,
    min = parsed.min,
    sec = parsed.sec,
    isdst = today.isdst,
  })
end

local function conversions_for(range)
  local raw = range.text
  local parsed = parse_input(raw)
  if not parsed then
    return nil, "Unsupported time format. Expected HH:MM, HH:MM:SS, or RFC3339 (YYYY-MM-DDTHH:MM:SSZ / ±HH:MM)."
  end

  local items = {}

  if parsed.kind == "time" then
    local epoch_local = epoch_from_local_date(parsed)
    local day = os.date("%Y-%m-%d", epoch_local)
    local here = tz_offset_colon("%Y-%m-%dT%H:%M:%S%z", epoch_local)
    local utc = os.date("!%Y-%m-%dT%H:%M:%SZ", epoch_local)

    table.insert(items, {
      text = "day (assume today)",
      value = day,
      preview = { text = day },
    })
    table.insert(items, {
      text = "here (assume today)",
      value = here,
      preview = { text = here },
    })
    table.insert(items, {
      text = "utc (assume today)",
      value = utc,
      preview = { text = utc },
    })
  else
    local day = string.format("%04d-%02d-%02d", parsed.year, parsed.month, parsed.day)
    local time = string.format("%02d:%02d", parsed.hour, parsed.min)
    local time_s = string.format("%02d:%02d:%02d", parsed.hour, parsed.min, parsed.sec)
    local time12h = time12(parsed.hour, parsed.min, parsed.sec, false)
    local time12h_s = time12(parsed.hour, parsed.min, parsed.sec, true)

    table.insert(items, { text = "day", value = day, preview = { text = day } })
    table.insert(items, { text = "time", value = time, preview = { text = time } })
    table.insert(items, { text = "time seconds", value = time_s, preview = { text = time_s } })
    table.insert(items, { text = "time 12h", value = time12h, preview = { text = time12h } })
    table.insert(items, { text = "time 12h seconds", value = time12h_s, preview = { text = time12h_s } })
  end

  return items
end

function M.convert_visual()
  local range = visual_selection()
  if not range then
    vim.notify("No visual selection", vim.log.levels.WARN)
    return
  end

  local items, err = conversions_for(range)
  if not items then
    vim.notify(err, vim.log.levels.WARN)
    return
  end

  snacks.picker.pick({
    title = "Time Convert",
    prompt = " ",
    items = items,
    format = "text",
    preview = "preview",
    confirm = function(picker, item)
      picker:close()
      if item and item.value then
        set_range_text(range, item.value)
      end
    end,
  })
end

return M
