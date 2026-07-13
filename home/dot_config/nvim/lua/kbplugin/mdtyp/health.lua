---@diagnostic disable: undefined-field
local logger = require("std.logger")
local M = {}

function M.check()
  vim.health.start("kbplugin.mdtyp")

  if vim.fn.executable("curl") == 1 then
    vim.health.ok("curl executable found")
  else
    vim.health.error("curl executable is missing")
  end

  local ok_plugin, plugin = pcall(require, "kbplugin.mdtyp")
  if not ok_plugin then
    vim.health.error("kbplugin.mdtyp failed to load")
    return
  end

  vim.health.ok("kbplugin.mdtyp loaded")

  local status = plugin.health()
  vim.health.info("enabled: " .. tostring(status.enabled))
  vim.health.info("timeout: " .. tostring(status.timeout))

  local explore = logger.explorer(plugin.logger())
  explore:health({ title = "log", tail = 10, sink = vim.health.info })
end

return M
