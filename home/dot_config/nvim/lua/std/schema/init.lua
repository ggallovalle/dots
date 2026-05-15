local ast = require("std.schema.ast")
local annotations = require("std.schema.annotations")
local validate = require("std.schema.validate")

local M = {}

M.string = ast.string
M.number = ast.number
M.boolean = ast.boolean
M.any = ast.any
M.array = ast.array
M.table = ast.table

M.optional = annotations.optional
M.default = annotations.default
M.description = annotations.description

M.validate = validate.validate

return M
