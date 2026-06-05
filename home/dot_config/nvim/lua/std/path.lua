local M = {}

---@class std.path.Path
---@field value string
local Path = {}
Path.__index = Path

function Path:__tostring()
  return self.value
end

--- Joins multiple path segments together, returning a new Path.
---@param ... string | std.path.Path
---@return std.path.Path
function Path:join(...)
  local t = { ... }
  ---@diagnostic disable-next-line: param-type-mismatch
  local add_to = vim.iter(t)
    :map(tostring)
    :totable()
  return M.new(vim.fs.joinpath(tostring(self), unpack(add_to)))
end

--- Creates a new Path from the given path string.
---@param value string
---@return std.path.Path
function M.new(value)
  vim.validate("value", value, "string")

  local instance = { value = value }
  return setmetatable(instance, Path)
end

return M
