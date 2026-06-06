---@type LazyPluginSpec
local Opencode = { url = "https://github.com/nickjvandyke/opencode.nvim.git" }

local show_gitignored = false

---@type LazyPluginSpec
local Oil = {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  init = function ()
    vim.g.loaded_netrwPlugin = 1
  end,
  opts = function()
    return {
      default_file_explorer = true,
      view_options = {
        is_always_hidden = function(name, bufnr)
          if show_gitignored then
            return false
          end
          local dir = require("oil").get_current_dir(bufnr)
          if not dir then
            return false
          end
          local ret = vim.fn.system({ "git", "-C", dir, "check-ignore", name })
          return vim.v.shell_error == 0
        end,
      },
      keymaps = {
        ["gi"] = {
          callback = function()
            show_gitignored = not show_gitignored
            require("oil.actions").refresh.callback()
          end,
          desc = "Toggle gitignored files",
        },
      },
    }
  end,
}

return { Opencode, Oil }
