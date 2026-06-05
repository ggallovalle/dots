---@diagnostic disable: undefined-field
local logger = require("std.logger")
local M = {}

---@param dep string
---@return string|nil
local function dep_name(dep)
    return vim.trim(dep):match("^([%w%._%-]+)")
end

---@param luarocks    string
---@param lua_version string
---@param dep         string
---@return boolean, string
local function check_dependency(luarocks, lua_version, dep)
    local name = dep_name(dep)
    if name == nil or name == "" then
        return false, ("invalid dependency declaration: %s"):format(dep)
    end

    local result = vim.system({
        luarocks,
        "--lua-version",
        lua_version,
        "show",
        name
    }, { text = true }):wait()

    if result.code == 0 then
        return true, ("%s (resolved as %s)"):format(dep, name)
    end

    local err = vim.trim(
        (result.stderr or "") ~= "" and result.stderr or (result.stdout or "")
    )
    if err == "" then
        err = "unknown error"
    end
    return false, ("%s (resolved as %s): %s"):format(dep, name, err)
end

function M.check()
    vim.health.start("kbplugin.luarocks")

    if vim.fn.executable("luarocks") == 1 then
        vim.health.ok("luarocks executable found")
    else
        vim.health.error("luarocks executable is missing")
    end

    local ok_plugin, plugin = pcall(require, "kbplugin.luarocks")
    if not ok_plugin then
        vim.health.error("kbplugin.luarocks failed to load")
        return
    end

    vim.health.ok("kbplugin.luarocks loaded")

    local status = plugin.health()
    vim.health.info("configured: " .. tostring(status.configured))
    vim.health.info("lua_version: " .. tostring(status.lua_version))
    vim.health.info("dependencies: "
        .. table.concat(status.dependencies or {}, ", "))
    vim.health.info("install_running: " .. tostring(status.install_running))
    vim.health.info("install_ok: " .. tostring(status.install_ok))
    if status.install_error ~= nil then
        vim.health.warn("install_error: " .. tostring(status.install_error))
    end
    vim.health.info("wired_path_count: " .. tostring(status.wired_path_count))
    vim.health.info("wired_cpath_count: " .. tostring(status.wired_cpath_count))
    vim.health.info("state_dir: " .. tostring(status.state_dir))
    vim.health.info("rockspec_path: " .. tostring(status.rockspec_path))

    local luarocks = vim.fn.exepath("luarocks")
    if luarocks ~= "" and status.configured
        and type(status.dependencies) == "table" then
        for _, dep in ipairs(status.dependencies) do
            local ok, detail = check_dependency(
                luarocks, status.lua_version or "5.1", dep
            )
            if ok then
                vim.health.ok("dependency installed: " .. detail)
            else
                vim.health.error("dependency missing: " .. detail)
            end
        end
    end

    local explore = logger.explorer(plugin.logger())
    explore:health({ title = "log", tail = 10, sink = vim.health.info })
end

return M
