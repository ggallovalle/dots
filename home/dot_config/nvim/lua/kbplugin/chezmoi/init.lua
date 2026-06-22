local internal = require("kbplugin.chezmoi.internal")

---@class kbplugin.chezmoi.UserConfig
---@field auto_apply_after_add? boolean
---@field log_level?            std.logger.Level

---@class kbplugin.chezmoi.Health
---@field enabled              boolean
---@field tracked_buffers      integer
---@field in_flight_jobs       integer
---@field chezmoi_config_path? string
---@field config               kbplugin.chezmoi.UserConfig

local M = {}

---@param opts? kbplugin.chezmoi.UserConfig
function M.setup(opts)
  internal.configure(opts)
  internal.register_commands()
end

---@return kbplugin.chezmoi.Health
function M.health()
  return internal.health()
end

---@return std.logger.Instance
function M.logger()
  return internal.logger()
end

---@return boolean
function M.is_enabled()
  return internal.is_enabled()
end

---@param enabled      boolean
---@param config_path? string
function M.set_enabled(enabled, config_path)
  internal.set_enabled(enabled, config_path)
end

---@param silent boolean
function M.disable(silent)
  internal.disable(silent)
end

---@return string?
function M.get_chezmoi_config_path()
  return internal.get_chezmoi_config_path()
end

return M
