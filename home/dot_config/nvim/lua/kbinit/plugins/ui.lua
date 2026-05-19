---@class ScreenkeyOpts
---@field keys table<string, string>

---@class CatppuccinOpts
---@field flavour string

---@class TypstPreviewOpts
---@field dependencies_bin table<string, string|nil>
---@field open_cmd string

---@type LazyPluginSpec
local Screenkey = {
  url = "https://github.com/NStefan002/screenkey.nvim.git",
  opts = function()
    ---@type ScreenkeyOpts
    local opts = {
      keys = {
        ["<TAB>"] = "Tab",
        ["<CR>"] = "Enter",
        ["<ESC>"] = "Esc",
        ["<SPACE>"] = "Space",
        ["<BS>"] = "Backspace",
        ["<DEL>"] = "Del",
        ["<LEFT>"] = "Left",
        ["<RIGHT>"] = "Right",
        ["<UP>"] = "Up",
        ["<DOWN>"] = "Down",
        ["<HOME>"] = "Home",
        ["<END>"] = "End",
        ["<PAGEUP>"] = "PgUp",
        ["<PAGEDOWN>"] = "PgDn",
        ["<INSERT>"] = "Ins",
        ["<F1>"] = "F1",
        ["<F2>"] = "F2",
        ["<F3>"] = "F3",
        ["<F4>"] = "F4",
        ["<F5>"] = "F5",
        ["<F6>"] = "F6",
        ["<F7>"] = "F7",
        ["<F8>"] = "F8",
        ["<F9>"] = "F9",
        ["<F10>"] = "F10",
        ["<F11>"] = "F11",
        ["<F12>"] = "F12",
        ["CTRL"] = "Ctrl",
        ["ALT"] = "Alt",
        ["SUPER"] = "Super",
        ["<leader>"] = "Spc",
      },
    }
    return opts
  end,
}

---@type LazyPluginSpec
local Devicons = {
  url = "https://github.com/nvim-tree/nvim-web-devicons.git",
  opts = function()
    ---@type table<string, any>
    local opts = {
      variant = "dark",
    }
    return opts
  end,
}

---@type LazyPluginSpec
local Catppuccin = {
  url = "https://github.com/catppuccin/nvim.git",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  opts = function()
    ---@type CatppuccinOpts
    local opts = {
      flavour = "mocha",
    }
    return opts
  end,
  config = function(_, opts)
    require("catppuccin").setup(opts)
    vim.cmd.colorscheme("catppuccin-nvim")
  end,
}

---@type LazyPluginSpec
local WhichKey = {
  url = "https://github.com/folke/which-key.nvim.git",
  opts = function()
    ---@type table<string, any>
    local opts = {}
    return opts
  end,
}

---@type snacks.Config
local snacks_opts = {
  input = {},
  picker = {
    actions = {
      opencode_send = function(...)
        return require("opencode").snacks_picker_send(...)
      end,
    },
    win = {
      input = {
        keys = {
          ["<a-a>"] = { "opencode_send", mode = { "n", "i" } },
        },
      },
    },
  },
}

---@type LazyPluginSpec
local Snacks = {
  url = "https://github.com/folke/snacks.nvim.git",
  opts = function()
    return snacks_opts
  end,
}

---@type LazyPluginSpec
local RenderMarkdown = {
  url = "https://github.com/MeanderingProgrammer/render-markdown.nvim.git",
  opts = function()
    ---@type table<string, any>
    local opts = {}
    return opts
  end,
}

---@type LazyPluginSpec
local TypstPreview = {
  url = "https://github.com/chomosuke/typst-preview.nvim.git",
  opts = function()
    ---@type TypstPreviewOpts
    local opts = {
      dependencies_bin = {
        tinymist = "tinymist",
        websocat = "websocat",
      },
      open_cmd = "firefox %s",
    }
    return opts
  end,
}

return {
  Screenkey,
  Devicons,
  Catppuccin,
  WhichKey,
  Snacks,
  RenderMarkdown,
  TypstPreview,
}
