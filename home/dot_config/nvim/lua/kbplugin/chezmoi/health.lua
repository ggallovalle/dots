---@diagnostic disable: undefined-field
local logger = require("std.logger")
local M = {}

function M.check()
  local ok_start, health = pcall(require, "vim.health")
  if not ok_start then
    return
  end

  health.start("kbplugin.chezmoi")

  if vim.fn.executable("chezmoi") == 1 then
    health.ok("chezmoi executable found")
  else
    health.error("chezmoi executable is missing")
  end

  local ok_plugin, plugin = pcall(require, "kbplugin.chezmoi")
  if not ok_plugin then
    health.error("kbplugin.chezmoi failed to load")
    return
  end

  health.ok("kbplugin.chezmoi loaded")

  local status = plugin.health()
  health.info("enabled: " .. tostring(status.enabled))
  health.info("tracked_buffers: " .. tostring(status.tracked_buffers))
  health.info("in_flight_jobs: " .. tostring(status.in_flight_jobs))
  health.info("auto_apply_after_add: " .. tostring(status.config.auto_apply_after_add))
  health.info("log_level: " .. tostring(status.config.log_level))

  local explore = logger.explorer(plugin.logger())
  explore:health(function(line)
    health.info(line)
  end, { title = "log", tail = 10 })
end

return M
