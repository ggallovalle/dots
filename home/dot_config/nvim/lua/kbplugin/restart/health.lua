---@diagnostic disable: undefined-field
local logger = require("std.logger")
local M = {}

function M.check()
  local ok_start, health = pcall(require, "vim.health")
  if not ok_start then
    return
  end

  health.start("kbplugin.restart")

  local ok_plugin, plugin = pcall(require, "kbplugin.restart")
  if not ok_plugin then
    health.error("kbplugin.restart failed to load")
    return
  end

  health.ok("kbplugin.restart loaded")
  local status = plugin.health()
  health.info("providers: " .. table.concat(status.providers, ", "))
  health.info("state_file: " .. status.state_file)
  health.info("session_file: " .. status.session_file)
  health.info("restore_done: " .. tostring(status.restore_done))

  local explore = logger.explorer(plugin.logger())
  explore:health(function(line)
    health.info(line)
  end, { title = "log", tail = 10 })
end

return M
