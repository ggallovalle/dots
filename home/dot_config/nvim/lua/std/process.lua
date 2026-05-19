local M = {}

---@class std.process.Command
---@field bin   string
---@field args  string[]
---@field opts? vim.SystemOpts

---@class std.process.Result
---@field code   integer
---@field stdout string
---@field stderr string

---@alias std.process.Callback fun(err: string?, result: std.process.Result?)

---@param bin   string
---@param args? string[]
---@param opts? vim.SystemOpts
---@return std.process.Command
function M.make(bin, args, opts)
    vim.validate("bin", bin, "string")
    args = args or {}
    opts = opts or {}
    return { bin = bin, args = vim.deepcopy(args), opts = vim.deepcopy(opts) }
end

---@param cmd std.process.Command
---@param cb  std.process.Callback
---@return vim.SystemObj
function M.execute_text(cmd, cb)
    local argv = { cmd.bin }
    vim.list_extend(argv, cmd.args)
    local opts = vim.tbl_extend("force", cmd.opts or {}, { text = true })
    return vim.system(argv, opts, function(out)
        if out.code == 0 then
            cb(nil, { code = out.code, stdout = out.stdout or "", stderr = out.stderr or "" })
            return
        end
        cb(nil, { code = out.code, stdout = out.stdout or "", stderr = out.stderr or "" })
    end)
end

---@param cmd std.process.Command
---@param cb  fun(err: string?, result: { code: integer, stdout: string[], stderr: string }?)
---@return vim.SystemObj
function M.execute_lines(cmd, cb)
    return M.execute_text(cmd, function(err, result)
        if err ~= nil or result == nil then
            cb(err, nil)
            return
        end
        cb(nil, {
            code = result.code,
            stdout = vim.split(result.stdout, "\n", { plain = true, trimempty = true }),
            stderr = result.stderr
        })
    end)
end

return M
