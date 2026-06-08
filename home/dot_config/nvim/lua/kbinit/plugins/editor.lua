---@type LazyPluginSpec
local Surround = {
  url = "https://github.com/kylechui/nvim-surround.git",
  ---@type kbinit.surround.Config
  opts = {}
}

---@type LazyPluginSpec
local AutoPairs = {
  url = "https://github.com/windwp/nvim-autopairs.git",
  ---@type kbinit.autopairs.Config
  opts = {}
}

---@type LazyPluginSpec
local AnsiNvim = {
  url = "https://github.com/0xferrous/ansi.nvim",
  opts = {
    -- Automatically enable for configured filetypes
    auto_enable = true,
    -- Automatically enable when buffer content was read from stdin
    -- Useful for commands like: cat file.log | nvim -
    auto_enable_stdin = true,
    -- Filetypes to auto-enable when auto_enable is true
    filetypes = { "log", "ansi" },
    -- Color theme: 'classic', 'modern', 'catppuccin', 'dracula', 'onedark', 'gruvbox', 'terminal'
    theme = "catppuccin"
  }
}

local HTextObjects = {}

function HTextObjects.select(query)
  return function ()
    local textobject = require("nvim-treesitter-textobjects.select")

      textobject.select_textobject(query, "textobjects")
  end
end

---@type LazyPluginSpec
local TreesitterTextObjects = {
  url = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  init = function ()
    vim.g.no_plugin_maps = true
  end,
  opts = {
    lookahead = true,
    selection_modes = {
      ['@parameter.outer'] = "v", -- charwise
      ['@function.outer'] = "V"   -- linewise
      -- ['@class.outer'] = '<c-v>', -- blockwise
    }
  },
  keys = {
    {
      "aa",
      HTextObjects.select("@parameter.outer"),
      mode = { "x", "o" },
      desc = "[A]rgument [A]rround"
    }
  }
}

return { Surround, AutoPairs, AnsiNvim, TreesitterTextObjects }
