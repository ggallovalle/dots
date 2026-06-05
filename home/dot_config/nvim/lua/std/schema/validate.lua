local M = {}

---@class std.schema.ValidationError
---@field code     string
---@field path     string
---@field expected string
---@field actual   string
---@field message  string

---@param value any
---@return string
local function type_name(value)
  local t = type(value)
  if t == "nil" then
    return "nil"
  end
  if t == "table" then
    return "table"
  end
  return t
end

---@param code     string
---@param path     string
---@param expected string
---@param value    any
---@return std.schema.ValidationError
local function mk_error(code, path, expected, value)
  local actual = type_name(value)
  return {
    code = code,
    path = path,
    expected = expected,
    actual = actual,
    message = string.format("%s: expected %s, got %s", path, expected, actual)
  }
end

---@param path string
---@param key  string | integer
---@return string
local function join_path(path, key)
  if type(key) == "number" then
    return string.format("%s[%d]", path, key)
  end
  if path == "$" then
    return path .. "." .. key
  end
  return path .. "." .. key
end

---@param node  std.schema.Node
---@param value any
---@param path  string
---@return boolean, std.schema.ValidationError?
local function validate_node(node, value, path)
  if value == nil and node.optional then
    return true, nil
  end

  if node.kind == "any" then
    return true, nil
  end

  if node.kind == "string" then
    if type(value) ~= "string" then
      return false, mk_error("invalid_type", path, "string", value)
    end
    return true, nil
  end

  if node.kind == "number" then
    if type(value) ~= "number" then
      return false, mk_error("invalid_type", path, "number", value)
    end
    return true, nil
  end

  if node.kind == "boolean" then
    if type(value) ~= "boolean" then
      return false, mk_error("invalid_type", path, "boolean", value)
    end
    return true, nil
  end

  if node.kind == "array" then
    if type(value) ~= "table" then
      return false, mk_error("invalid_type", path, "array", value)
    end
    local element = node.element
    if element == nil then
      return false, {
          code = "invalid_schema",
          path = path,
          expected = "array element schema",
          actual = "nil",
          message = path .. ": array schema missing element node"
        }
    end
    for i, v in ipairs(value) do
      local ok, err = validate_node(element, v, join_path(path, i))
      if not ok then
        return false, err
      end
    end
    return true, nil
  end

  ---@diagnostic disable-next-line: unnecessary-if
  if node.kind == "table" then
    if type(value) ~= "table" then
      return false, mk_error("invalid_type", path, "table", value)
    end
    local fields = node.fields or {}
    for key, field in pairs(fields) do
      local has = value[key] ~= nil
      if not has and not field.optional then
        return false, {
            code = "missing_field",
            path = join_path(path, key),
            expected = field.kind,
            actual = "missing",
            message = string.format("%s: required field is missing", join_path(path, key))
          }
      end
      if has then
        local ok, err = validate_node(field, value[key], join_path(path, key))
        if not ok then
          return false, err
        end
      end
    end
    return true, nil
  end

  return false, {
      code = "unknown_schema_kind",
      path = path,
      expected = "known schema kind",
      actual = tostring(node.kind),
      message = string.format("%s: unknown schema kind %s", path, tostring(node.kind))
    }
end

---@param ast   std.schema.Node
---@param value any
---@return boolean, std.schema.ValidationError?
function M.validate(ast, value)
  return validate_node(ast, value, "$")
end

return M
