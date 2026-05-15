local M = {}

---@alias std.schema.NodeKind "string"|"number"|"boolean"|"any"|"array"|"table"

---@class std.schema.Node
---@field kind std.schema.NodeKind
---@field optional? boolean
---@field default? any
---@field description? string
---@field element? std.schema.Node
---@field fields? table<string, std.schema.Node>

---@param node std.schema.Node
---@param ... fun(node: std.schema.Node): std.schema.Node
---@return std.schema.Node
local function pipe_impl(node, ...)
  local out = node
  for _, fn in ipairs({ ... }) do
    out = fn(out)
  end
  return out
end

---@param node std.schema.Node
---@return std.schema.Node
local function attach_pipe(node)
  ---@param self std.schema.Node
  ---@param ... fun(node: std.schema.Node): std.schema.Node
  function node:pipe(...)
    return pipe_impl(self, ...)
  end
  return node
end

---@return std.schema.Node
function M.string()
  return attach_pipe({ kind = "string" })
end

---@return std.schema.Node
function M.number()
  return attach_pipe({ kind = "number" })
end

---@return std.schema.Node
function M.boolean()
  return attach_pipe({ kind = "boolean" })
end

---@return std.schema.Node
function M.any()
  return attach_pipe({ kind = "any" })
end

---@param element std.schema.Node
---@return std.schema.Node
function M.array(element)
  return attach_pipe({ kind = "array", element = element })
end

---@param fields table<string, std.schema.Node>
---@return std.schema.Node
function M.table(fields)
  return attach_pipe({ kind = "table", fields = fields })
end

return M
