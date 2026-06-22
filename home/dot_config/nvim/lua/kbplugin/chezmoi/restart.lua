local schema = require("std.schema")

local M = {}

M.schema = schema.table({
  enabled = schema
    .boolean()
    :pipe(schema.description("Whether chezmoi autosync plugin is enabled")),
  chezmoi_config_path = schema
    .optional(schema
      .string()
      :pipe(schema.description("Path to chezmoi config file")))
})

function M.snapshot()
  local chezmoi = require("kbplugin.chezmoi")
  local data = { enabled = chezmoi.is_enabled() }
  local path = chezmoi.get_chezmoi_config_path()
  if path then
    data.chezmoi_config_path = path
  end
  return data
end

function M.restore(data)
  local chezmoi = require("kbplugin.chezmoi")
  if type(data) ~= "table" then
    return
  end
  if data.enabled == true then
    local config_path = data.chezmoi_config_path or ""
    chezmoi.set_enabled(true, config_path)
  else
    chezmoi.disable(true)
  end
end

return M
