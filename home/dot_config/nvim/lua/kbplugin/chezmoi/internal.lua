local process = require("std.process")
local logger = require("std.logger")

---@class kbplugin.chezmoi.BufferState
---@field kind        "source"|"target"|"unmanaged"
---@field opened_path string?
---@field source_path string?
---@field target_path string?

---@class kbplugin.chezmoi.RuntimeState
---@field enabled boolean
---@field augroup integer?
---@field buffers table<integer, kbplugin.chezmoi.BufferState>
---@field jobs    table<integer, vim.SystemObj>
---@field config  kbplugin.chezmoi.UserConfig

local M = {}

local H = {}

---@type kbplugin.chezmoi.RuntimeState
local state = {
    enabled = false,
    augroup = nil,
    buffers = {},
    jobs = {},
    config = {
        auto_apply_after_add = false,
        log_level = "info"
    }
}

local log = logger.new({
    path = vim.fn.stdpath("state") .. "/kbplugin/chezmoi.log",
    max_bytes = 1024 * 1024,
    level = "info"
})

local function notify(msg, level)
    vim.notify("[kb.chezmoi] " .. msg, level or vim.log.levels.INFO)
end

local function trim(s)
    return (s or ""):gsub("^%s+", ""):gsub("%s+$", "")
end

local function current_path(bufnr)
    local name = vim.api.nvim_buf_get_name(bufnr)
    if name == "" then
        return nil
    end
    local abs = vim.fn.fnamemodify(name, ":p")
    return vim.uv.fs_realpath(abs) or abs
end

---@param bufnr   integer
---@param payload table
local function set_buffer_state(bufnr, payload)
    state.buffers[bufnr] = vim.tbl_deep_extend("force", state.buffers[bufnr] or {}, payload)
end

---@param bufnr integer
---@param cb    fun(state: kbplugin.chezmoi.BufferState)
function H.detect_buffer(bufnr, cb)
    local opened_path = current_path(bufnr)
    if opened_path == nil then
        set_buffer_state(bufnr, { kind = "unmanaged", opened_path = nil })
        cb(state.buffers[bufnr])
        return
    end

    local cmd_target = process.make("chezmoi", { "source-path", opened_path })
    process.execute_text(cmd_target, function(err, result)
        if err ~= nil or result == nil then
            set_buffer_state(bufnr, { kind = "unmanaged", opened_path = opened_path })
            cb(state.buffers[bufnr])
            return
        end

        if result.code == 0 then
            set_buffer_state(bufnr, {
                kind = "target",
                opened_path = opened_path,
                target_path = opened_path,
                source_path = trim(result.stdout)
            })
            cb(state.buffers[bufnr])
            return
        end

        local cmd_source = process.make("chezmoi", { "target-path", "--source-path", opened_path })
        process.execute_text(cmd_source, function(_err2, result2)
            if result2 ~= nil and result2.code == 0 then
                set_buffer_state(bufnr, {
                    kind = "source",
                    opened_path = opened_path,
                    source_path = opened_path,
                    target_path = trim(result2.stdout)
                })
            else
                set_buffer_state(bufnr, { kind = "unmanaged", opened_path = opened_path })
            end
            cb(state.buffers[bufnr])
        end)
    end)
end

---@param bufnr integer
local function stop_job(bufnr)
    local job = state.jobs[bufnr]
    if job == nil then
        return
    end
    pcall(function()
        job:kill(15)
    end)
    state.jobs[bufnr] = nil
    log:debug("cancelled in-flight run", { bufnr = bufnr })
end

---@param bufnr      integer
---@param cmd        std.process.Command
---@param base_event table
---@param done?      fun(ok: boolean)
local function start_command(bufnr, cmd, base_event, done)
    stop_job(bufnr)

    local start_ms = vim.uv.hrtime()
    local ev = log:event("chezmoi.save", base_event)
    ev:set({ command = { bin = cmd.bin, args = cmd.args, cwd = cmd.opts and cmd.opts.cwd or nil } })

    state.jobs[bufnr] = process.execute_text(cmd, function(err, result)
        state.jobs[bufnr] = nil
        local duration_ms = math.floor((vim.uv.hrtime() - start_ms) / 1000000)
        if err ~= nil or result == nil then
            ev:set_level("error")
            ev:set({ run = { status = "error", duration_ms = duration_ms } })
            ev:emit("chezmoi command transport failure")
            notify("command failed to start", vim.log.levels.ERROR)
            if done then
                done(false)
            end
            return
        end

        if result.code == 0 then
            ev:set({ run = { status = "ok", code = result.code, duration_ms = duration_ms } })
            if state.config.log_level == "debug" then
                ev:set({ io = { stdout = result.stdout, stderr = result.stderr } })
            end
            ev:emit("chezmoi command ok")
            if done then
                done(true)
            end
            return
        end

        ev:set_level("error")
        ev:set({
            run = { status = "error", code = result.code, duration_ms = duration_ms },
            io = { stderr = result.stderr }
        })
        ev:emit("chezmoi command error")
        notify("command failed (exit " .. tostring(result.code) .. ")", vim.log.levels.ERROR)
        if done then
            done(false)
        end
    end)
end

---@param bufnr integer
function H.run_for_buffer(bufnr)
    local bs = state.buffers[bufnr]
    if bs == nil then
        H.detect_buffer(bufnr, function()
            H.run_for_buffer(bufnr)
        end)
        return
    end

    if bs.kind == "unmanaged" then
        return
    end

    local base_event = {
        bufnr = bufnr,
        file = {
            opened_path = bs.opened_path,
            kind = bs.kind,
            source_path = bs.source_path,
            target_path = bs.target_path
        }
    }

    if bs.kind == "source" then
        local cmd = process.make("chezmoi", { "apply", "--source-path", bs.source_path })
        start_command(bufnr, cmd, base_event)
        return
    end

    local cmd = process.make("chezmoi", { "add", bs.target_path })
    start_command(bufnr, cmd, base_event, function(ok)
        if not ok or not state.config.auto_apply_after_add then
            return
        end
        local apply_cmd = process.make("chezmoi", { "apply", "--source-path", bs.source_path })
        start_command(bufnr, apply_cmd, base_event)
    end)
end

---@param bufnr integer
function H.refresh_buffer(bufnr)
    H.detect_buffer(bufnr, function(_) end)
end

local function on_buf_event(args)
    if not state.enabled then
        return
    end
    H.refresh_buffer(args.buf)
end

local function on_write(args)
    if not state.enabled then
        return
    end
    H.run_for_buffer(args.buf)
end

local function on_wipeout(args)
    local bufnr = args.buf
    stop_job(bufnr)
    state.buffers[bufnr] = nil
end

---@param force_all boolean
function M.enable(force_all)
    if state.enabled and not force_all then
        return
    end
    state.enabled = true

    if state.augroup == nil then
        state.augroup = vim.api.nvim_create_augroup("kb_chezmoi", { clear = true })
    end

    vim.api.nvim_create_autocmd({ "BufReadPost", "BufEnter" }, {
        group = state.augroup,
        callback = on_buf_event
    })

    vim.api.nvim_create_autocmd("BufWritePost", {
        group = state.augroup,
        callback = on_write
    })

    vim.api.nvim_create_autocmd("BufWipeout", {
        group = state.augroup,
        callback = on_wipeout
    })

    H.refresh_buffer(vim.api.nvim_get_current_buf())

    if force_all then
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then
                H.refresh_buffer(bufnr)
            end
        end
    end
end

---@param silent boolean
function M.disable(silent)
    state.enabled = false
    if state.augroup ~= nil then
        pcall(vim.api.nvim_del_augroup_by_id, state.augroup)
        state.augroup = nil
    end
    for bufnr, _ in pairs(state.jobs) do
        stop_job(bufnr)
    end
    if not silent then
        notify("disabled")
    end
end

---@param force_all boolean
function M.refresh(force_all)
    if force_all then
        for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
            if vim.api.nvim_buf_is_loaded(bufnr) then
                H.refresh_buffer(bufnr)
            end
        end
        return
    end
    H.refresh_buffer(vim.api.nvim_get_current_buf())
end

function M.run_current()
    H.run_for_buffer(vim.api.nvim_get_current_buf())
end

---@return boolean
function M.is_enabled()
    return state.enabled
end

---@param enabled boolean
function M.set_enabled(enabled)
    if enabled then
        M.enable(false)
    else
        M.disable(true)
    end
end

function M.register_commands()
    vim.api.nvim_create_user_command("ChezmoiEnable", function(args)
        M.enable(args.bang)
        notify("enabled")
    end, { bang = true }
    )

    vim.api.nvim_create_user_command("ChezmoiDisable", function(args)
        M.disable(args.bang)
    end, { bang = true }
    )

    vim.api.nvim_create_user_command("ChezmoiToggle", function(args)
        if state.enabled then
            M.disable(false)
        else
            M.enable(args.bang)
            notify("enabled")
        end
    end, { bang = true }
    )

    vim.api.nvim_create_user_command("ChezmoiRefresh", function(args)
        M.refresh(args.bang)
        notify("refreshed")
    end, { bang = true }
    )

    vim.api.nvim_create_user_command("ChezmoiRun", function()
        M.run_current()
    end, {}
    )
end

---@param opts? kbplugin.chezmoi.UserConfig
function M.configure(opts)
    state.config = vim.tbl_deep_extend("force", state.config, opts or {})
    log = logger.new({
        path = vim.fn.stdpath("state") .. "/kbplugin/chezmoi.log",
        max_bytes = 1024 * 1024,
        level = state.config.log_level
    })
end

---@return kbplugin.chezmoi.Health
function M.health()
    return {
        enabled = state.enabled,
        tracked_buffers = vim.tbl_count(state.buffers),
        in_flight_jobs = vim.tbl_count(state.jobs),
        config = vim.deepcopy(state.config)
    }
end

---@return std.logger.Instance
function M.logger()
    return log
end

return M
