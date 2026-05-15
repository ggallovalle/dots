---@diagnostic disable: undefined-field
local logger = require("std.logger")
local M = {}

function M.check()
  local ok_start, health = pcall(require, "vim.health")
  if not ok_start then
    return
  end

  health.start("kbplugins.chezmoi")

  if vim.fn.executable("chezmoi") == 1 then
    health.ok("chezmoi executable found")
  else
    health.error("chezmoi executable is missing")
  end

  local ok_plugin, plugin = pcall(require, "kbplugins.chezmoi")
  if not ok_plugin then
    health.error("kbplugins.chezmoi failed to load")
    return
  end

  health.ok("kbplugins.chezmoi loaded")

  local status = plugin.health()
  health.info("enabled: " .. tostring(status.enabled))
  health.info("tracked_buffers: " .. tostring(status.tracked_buffers))
  health.info("in_flight_jobs: " .. tostring(status.in_flight_jobs))
  health.info("auto_apply_after_add: " .. tostring(status.config.auto_apply_after_add))
  health.info("log_level: " .. tostring(status.config.log_level))

  local explore = logger.explorer(plugin.logger())
  if not explore:exists() then
    health.info("log file: not created yet")
    return
  end

  health.info("log file: " .. explore:path())
  local tail = explore:tail(10)
  if #tail == 0 then
    health.info("last logs: (empty)")
    return
  end

  health.info("last 10 log lines:")
  for _, line in ipairs(tail) do
    health.info(line)
  end
end

return M
