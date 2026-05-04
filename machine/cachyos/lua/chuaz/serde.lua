
---@meta chuaz.serde

---@class chuaz.serde.json
local json = {}

---@param value any
---@return string?
---@return string?
function json.serialize(value) end

---@param data string
---@return any?
---@return string?
function json.deserialize(data) end

---@class chuaz.serde.toml
local toml = {}

---@param value any
---@return string?
---@return string?
function toml.serialize(value) end

---@param data string
---@return any?
---@return string?
function toml.deserialize(data) end

---@class chuaz.serde.yaml
local yaml = {}

---@param value any
---@return string?
---@return string?
function yaml.serialize(value) end

---@param data string
---@return any?
---@return string?
function yaml.deserialize(data) end

---@class chuaz.serde.jsonc
local jsonc = {}

---@param value any
---@return string?
---@return string?
function jsonc.serialize(value) end

---@param data string
---@return any?
---@return string?
function jsonc.deserialize(data) end

local serde = {
	json = json,
	toml = toml,
	yaml = yaml,
	jsonc = jsonc,
}

return serde
