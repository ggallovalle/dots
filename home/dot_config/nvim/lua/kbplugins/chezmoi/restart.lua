local schema = require("std.schema")

local M = {}

M.schema = schema.table({
  enabled = schema.boolean():pipe(
    schema.description("Whether chezmoi autosync plugin is enabled")
  )
})

function M.snapshot()
  local chezmoi = require("kbplugins.chezmoi")
  return {
    enabled = chezmoi.is_enabled()
  }
end

function M.restore(data)
  local chezmoi = require("kbplugins.chezmoi")
  if type(data) ~= "table" then
    return
  end
  chezmoi.set_enabled(data.enabled == true)
end

return M
