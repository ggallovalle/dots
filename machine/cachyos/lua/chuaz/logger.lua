
---@meta chuaz.logger

---@alias chuaz.logger.LogLevel
---| '"DEBUG"' # Debug level
---| '"INFO"'  # Info level
---| '"WARN"'  # Warn level
---| '"ERROR"' # Error level

---@class chuaz.logger.Logger
---@field level chuaz.logger.LogLevel
local Logger = {}

---@param msg string
---@param attrs? table
function Logger:debug(msg, attrs) end

---@param msg string
---@param attrs? table
function Logger:info(msg, attrs) end

---@param msg string
---@param attrs? table
function Logger:warn(msg, attrs) end

---@param msg string
---@param attrs? table
function Logger:error(msg, attrs) end

---@param level chuaz.logger.LogLevel
---@param msg string
---@param attrs? table
function Logger:log(level, msg, attrs) end
