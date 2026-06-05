local logger = require("std.logger")
local schema = require("std.schema")

---@class kbplugin.restart.Provider
---@field snapshot fun(): table?
---@field restore  fun(data: table?): nil
---@field schema?  std.schema.Node

---@class kbplugin.restart.UserConfig
---@field providers? string[]
---@field log_level? std.logger.Level

---@class kbplugin.restart.RuntimeState
---@field config       kbplugin.restart.UserConfig
---@field providers    table<string, kbplugin.restart.Provider>
---@field files        { dir: string, session: string, state: string }
---@field restore_done boolean

local M = {}

---@type kbplugin.restart.RuntimeState
local state = {
  config = {
    providers = {},
    log_level = "info"
  },
  providers = {},
  files = {
    dir = vim.fn.stdpath("state") .. "/kbplugin/restart",
    session = vim.fn.stdpath("state") .. "/kbplugin/restart/session.vim",
    state = vim.fn.stdpath("state") .. "/kbplugin/restart/state.json"
  },
  restore_done = false
}

local log = logger.new({
  path = vim.fn.stdpath("state") .. "/kbplugin/restart.log",
  max_bytes = 1024 * 1024,
  level = "info"
})

local function notify(msg, level)
  vim.notify("[kb.restart] " .. msg, level or vim.log.levels.INFO)
end

local function ensure_dir()
  vim.fn.mkdir(state.files.dir, "p")
end

---@param path string
---@return string
local function esc(path)
  return vim.fn.fnameescape(path)
end

local function write_state_file(payload)
  ensure_dir()
  local encoded = vim.json.encode(payload)
  vim.fn.writefile({ encoded }, state.files.state)
end

local function read_state_file()
  local stat = vim.uv.fs_stat(state.files.state)
  if stat == nil then
    return nil
  end
  local lines = vim.fn.readfile(state.files.state)
  local raw = table.concat(lines, "\n")
  local ok, decoded = pcall(vim.json.decode, raw)
  if not ok then
    log:error("failed to decode restart state", { path = state.files.state })
    return nil
  end
  return decoded
end

local function cleanup_files()
  vim.fs.rm(state.files.state, { force = true })
  vim.defer_fn(function ()
    vim.fs.rm(state.files.session, { force = true })
  end, 5000)
end

local function load_provider(module_name)
  local ok, provider = pcall(require, module_name .. ".restart")
  if not ok then
    notify("provider module missing: " .. module_name, vim.log.levels.WARN)
    log:warn("provider load failed", { module = module_name })
    return
  end
  if type(provider) ~= "table" or type(provider.snapshot) ~= "function"
    or type(provider.restore) ~= "function" then
    notify("invalid provider: " .. module_name, vim.log.levels.WARN)
    log:warn("provider invalid", { module = module_name })
    return
  end
  state.providers[module_name] = provider
end

---@param provider_name string
---@param provider      kbplugin.restart.Provider
---@param data          any
---@param phase         "snapshot" | "restore"
---@return boolean
local function validate_provider_data(provider_name, provider, data, phase)
  if provider.schema == nil then
    return true
  end

  local ok, err = schema.validate(provider.schema, data)
  if ok then
    return true
  end

  local message = "schema validation failed"
  if err ~= nil and err.message ~= nil then
    message = err.message
  end
  notify(
    string.format("%s schema failed: %s", provider_name, message),
    vim
      .log
      .levels
      .WARN
  )
  log:warn("provider schema validation failed", {
    module = provider_name,
    phase = phase,
    error = err
  })
  return false
end

function M.configure(opts)
  state.config = vim.tbl_deep_extend("force", state.config, opts or {})
  state.providers = {}
  log = logger.new({
    path = vim.fn.stdpath("state") .. "/kbplugin/restart.log",
    max_bytes = 1024 * 1024,
    level = state.config.log_level
  })

  for _, module_name in ipairs(state.config.providers or {}) do
    load_provider(module_name)
  end
end

function M.restart()
  local providers_payload = {}
  for name, provider in pairs(state.providers) do
    local ok, data = pcall(provider.snapshot)
    if ok then
      if validate_provider_data(name, provider, data, "snapshot") then
        providers_payload[name] = data
      end
    else
      notify("snapshot failed: " .. name, vim.log.levels.WARN)
      log:warn("provider snapshot failed", { module = name })
    end
  end

  ensure_dir()
  vim.cmd("mksession! " .. esc(state.files.session))

  if vim.uv.fs_stat(state.files.session) == nil then
    notify("restart session file was not created", vim.log.levels.ERROR)
    log:error("session file missing after mksession", {
      path = state.files.session
    })
    return
  end

  write_state_file({
    meta = {
      timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
      ---@diagnostic disable-next-line: call-non-callable
      nvim = tostring(vim.version())
    },
    session_path = state.files.session,
    providers = providers_payload
  })

  vim.cmd.restart("source " .. esc(state.files.session))
end

function M.restore_once()
  if state.restore_done then
    return
  end
  state.restore_done = true

  local persisted = read_state_file()
  if persisted == nil or type(persisted.providers) ~= "table" then
    return
  end

  for name, provider in pairs(state.providers) do
    local restore_data = persisted.providers[name]
    if validate_provider_data(name, provider, restore_data, "restore") then
      local ok = pcall(provider.restore, restore_data)
      if not ok then
        notify("restore failed: " .. name, vim.log.levels.WARN)
        log:warn("provider restore failed", { module = name })
      end
    end
  end

  cleanup_files()
end

function M.register_commands()
  vim.api.nvim_create_user_command("KbRestart", function ()
    M.restart()
  end, {}
  )
end

function M.register_restore_autocmd()
  local group = vim.api.nvim_create_augroup("kb_restart_restore", {
    clear = true
  })
  vim.api.nvim_create_autocmd("VimEnter", {
    group = group,
    once = true,
    callback = function ()
      M.restore_once()
    end
  })
end

function M.health()
  return {
    providers = vim.tbl_keys(state.providers),
    state_file = state.files.state,
    session_file = state.files.session,
    restore_done = state.restore_done
  }
end

---@return std.logger.Instance
function M.logger()
  return log
end

return M
