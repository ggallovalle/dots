---@type LazyPluginSpec
local Opencode = { url = "https://github.com/nickjvandyke/opencode.nvim.git" }

---@type LazyPluginSpec
local Oil = {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function ()
    vim.g.loaded_netrwPlugin = 1
  end,
  opts = {
    default_file_explorer = true,
  }
}

return { Opencode, Oil }
