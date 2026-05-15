local internal = require("kbplugins.chezmoi.internal")

---@class kbplugin.chezmoi.UserConfig
---@field auto_apply_after_add? boolean
---@field log_level? std.logger.Level

---@class kbplugin.chezmoi.Health
---@field enabled boolean
---@field tracked_buffers integer
---@field in_flight_jobs integer
---@field config kbplugin.chezmoi.UserConfig

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

return M
