local internal = require("kbplugin.restart.internal")

---@class kbplugin.restart.UserConfig
---@field providers? string[]
---@field log_level? std.logger.Level

local M = {}

---@param opts? kbplugin.restart.UserConfig
function M.setup(opts)
  internal.configure(opts)
  internal.register_commands()
  internal.register_restore_autocmd()
end

function M.restart()
  internal.restart()
end

function M.health()
  return internal.health()
end

---@return std.logger.Instance
function M.logger()
  return internal.logger()
end

return M
