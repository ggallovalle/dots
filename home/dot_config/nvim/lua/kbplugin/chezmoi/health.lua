---@diagnostic disable: undefined-field
local logger = require("std.logger")
local M = {}

function M.check()
    vim.health.start("kbplugin.chezmoi")

    if vim.fn.executable("chezmoi") == 1 then
        vim.health.ok("chezmoi executable found")
    else
        vim.health.error("chezmoi executable is missing")
    end

    local ok_plugin, plugin = pcall(require, "kbplugin.chezmoi")
    if not ok_plugin then
        vim.health.error("kbplugin.chezmoi failed to load")
        return
    end

    vim.health.ok("kbplugin.chezmoi loaded")

    local status = plugin.health()
    vim.health.info("enabled: " .. tostring(status.enabled))
    vim.health.info("tracked_buffers: " .. tostring(status.tracked_buffers))
    vim.health.info("in_flight_jobs: " .. tostring(status.in_flight_jobs))
    vim.health.info("auto_apply_after_add: " .. tostring(status.config.auto_apply_after_add))
    vim.health.info("log_level: " .. tostring(status.config.log_level))

    local explore = logger.explorer(plugin.logger())
    explore:health({ title = "log", tail = 10, sink = vim.health.info })
end

return M
