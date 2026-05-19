---@class YaziOpts
---@field open_for_directories boolean

---@type LazyPluginSpec
local Opencode = {
  url = "https://github.com/nickjvandyke/opencode.nvim.git",
}

---@type LazyPluginSpec
local Yazi = {
  url = "https://github.com/mikavilpas/yazi.nvim.git",
  init = function()
    vim.g.loaded_netrwPlugin = 1
  end,
  opts = function()
    ---@type YaziOpts
    local opts = {
      open_for_directories = true,
    }
    return opts
  end,
}

return {
  Opencode,
  Yazi,
}
