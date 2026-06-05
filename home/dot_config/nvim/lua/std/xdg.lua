local path = require("std.path")

local H = {}

function H.data()
  local value = vim.fn.stdpath("data")
  if type(value) == "string" then
    return path.new(value)
  end
  local first = value[0]
  if first then
    return path.new(first)
  end
  error("XDG_DATA_PATH has no values")
end

---@class std.xdg.Xdg
---@field data std.path.Path # XDG_DATA_PATH
local M = {}

setmetatable(M, {
  __index = function (_, key)
    if key == "data" then
      return H.data()
    end
  end
})

return M
