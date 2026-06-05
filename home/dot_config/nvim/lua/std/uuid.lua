---@alias std.async.Callback<T> fun(error: string?, result: T?): nil

local M = {}

---@param callback std.async.Callback<string>
function M.async_uuid(callback)
  vim.system({ "uuidgen" }, { text = true }, function (out)
    callback(out.stderr, out.stdout)
  end)
end

return M
