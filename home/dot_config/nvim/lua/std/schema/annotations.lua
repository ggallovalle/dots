local M = {}

---@param node std.schema.Node
---@return std.schema.Node
function M.optional(node)
    local next = vim.deepcopy(node)
    next.optional = true
    return next
end

---@param value any
---@return fun(node: std.schema.Node): std.schema.Node
function M.default(value)
    return function(node)
        local next = vim.deepcopy(node)
        next.optional = true
        next.default = value
        return next
    end
end

---@param text string
---@return fun(node: std.schema.Node): std.schema.Node
function M.description(text)
    return function(node)
        local next = vim.deepcopy(node)
        next.description = text
        return next
    end
end

return M
