
---@meta chuaz.path

---@class chuaz.path.PathParsed
---@field root string
---@field dir string
---@field base string
---@field ext string
---@field name string

---@class chuaz.path.Path
---@field sep string
local Path = {}

---@param path string
---@param suffix? string
---@return string
function Path.basename(path, suffix) end

---@param path string
---@return string
function Path.dirname(path) end

---@param path string
---@return string
function Path.extname(path) end

---@param pathObject chuaz.path.PathParsed
---@return string
function Path.format(pathObject) end

---@param url string
---@return string? data
---@return string? err
---@return_overload string, nil
---@return_overload nil, string
function Path.from_file_url(url) end

---@param path string
---@return boolean
function Path.is_absolute(path) end

---@param ... string
---@return string
function Path.join(...) end

---@param path string
---@return string
function Path.normalize(path) end

---@param path string
---@return chuaz.path.PathParsed
function Path.parse(path) end

---@param from string
---@param to string
---@return string? data
---@return string? err
---@return_overload string, nil
---@return_overload nil, string
function Path.relative(from, to) end

---@param ... string
---@return string? data
---@return string? err
---@return_overload string, nil
---@return_overload nil, string
function Path.resolve(...) end

---@param path string
---@return string? data
---@return string? err
---@return_overload string, nil
---@return_overload nil, string
function Path.to_file_url(path) end

---@param path string
---@return string
function Path.to_namespaced_path(path) end

return Path
