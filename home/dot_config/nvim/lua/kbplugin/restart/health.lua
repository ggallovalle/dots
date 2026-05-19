---@diagnostic disable: undefined-field
local logger = require("std.logger")
local M = {}

function M.check()
    vim.health.start("kbplugin.restart")

    local ok_plugin, plugin = pcall(require, "kbplugin.restart")
    if not ok_plugin then
        vim.health.error("kbplugin.restart failed to load")
        return
    end

    vim.health.ok("kbplugin.restart loaded")
    local status = plugin.health()
    vim.health.info("providers: " .. table.concat(status.providers, ", "))
    vim.health.info("state_file: " .. status.state_file)
    vim.health.info("session_file: " .. status.session_file)
    vim.health.info("restore_done: " .. tostring(status.restore_done))

    local explore = logger.explorer(plugin.logger())
    explore:health({ title = "log", tail = 10, sink = vim.health.info })
end

return M
