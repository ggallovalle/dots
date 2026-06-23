local M = {}

--- Resolve module directory from module name
local function module_dir(modname)
  local base = modname:gsub("%.", "/")
  for _, path in ipairs(vim.api.nvim_get_runtime_file("lua/" .. base, false)) do
    local stat = vim.uv.fs_stat(path)
    if stat and stat.type == "directory" then return path end
  end
end

--- Scan languages/*.lua, require each, return list of specs
local function collect()
  local specs = {}
  local dir = module_dir("kbinit.languages")
  if not dir then return specs end
  local handle = vim.uv.fs_scandir(dir)
  while handle do
    local name, ftype = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if ftype == "file" and name ~= "init.lua" and name:match("%.lua$") then
      local mod = name:gsub("%.lua$", "")
      specs[#specs + 1] = require("kbinit.languages." .. mod)
    end
  end
  return specs
end

--- Cache specs on first call
local _specs
local function specs()
  if not _specs then _specs = collect() end
  return _specs
end

function M.setup_lsp()
  for _, lang in ipairs(specs()) do
    if lang.lsp then
      for name, cfg in pairs(lang.lsp) do
        if type(cfg) == "function" then cfg = cfg() end
        if type(cfg) == "table" then vim.lsp.config(name, cfg) end
        vim.lsp.enable(name)
      end
    end
  end
end

function M.get_mason_ensure_installed()
  local result = {}
  for _, lang in ipairs(specs()) do
    if lang.mason then vim.list_extend(result, lang.mason) end
  end
  return result
end

function M.get_treesitter_parsers()
  local result = {}
  for _, lang in ipairs(specs()) do
    if lang.treesitter then vim.list_extend(result, lang.treesitter) end
  end
  return result
end

function M.get_conform_config()
  local by_ft = {}
  local formatters = {}
  for _, lang in ipairs(specs()) do
    if lang.conform then
      local cfg = type(lang.conform) == "function" and lang.conform() or lang.conform
      if cfg.formatters_by_ft then
        for ft, fmts in pairs(cfg.formatters_by_ft) do by_ft[ft] = fmts end
      end
      if cfg.formatters then
        for name, fmt_cfg in pairs(cfg.formatters) do formatters[name] = fmt_cfg end
      end
    end
  end
  return { formatters_by_ft = by_ft, formatters = formatters }
end

return M