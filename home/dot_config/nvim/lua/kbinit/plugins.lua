local M = {}
local Plugin = {}

function Plugin.screenkey()
  vim.pack.add({
    { src = "https://github.com/NStefan002/screenkey.nvim.git" }
  }, { confirm = false })

  require("screenkey").setup({
    ---@diagnostic disable-next-line: missing-fields
    ---@diagnostic disable-next-line: param-type-mismatch
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
      ["<leader>"] = "Spc"
    }
  })
end

function Plugin.opencode()
  vim.pack.add({
    { src = "https://github.com/nickjvandyke/opencode.nvim" }
  }, { confirm = false })
end

function Plugin.yazi()
  vim.pack.add({
    { src = "https://github.com/mikavilpas/yazi.nvim" }
  }, { confirm = false })
  require("yazi").setup({
    open_for_directories = true
  })
  vim.g.loaded_netrwPlugin = 1
end

function Plugin.devicons()
  vim.pack.add({
    { src = "https://github.com/nvim-tree/nvim-web-devicons" }
  }, { confirm = false })
  require("nvim-web-devicons").setup({
    variant = "dark"
  })
end

function Plugin.catppuccin()
  vim.pack.add({
    { src = "https://github.com/catppuccin/nvim", name = "catppuccin" }
  }, { confirm = false })

  require("catppuccin").setup({ flavour = "mocha" })
  vim.cmd.colorscheme "catppuccin-nvim"
end

function Plugin.markdown()
  vim.pack.add({
    "https://github.com/MeanderingProgrammer/render-markdown.nvim"
  }, { confirm = false })
  require("render-markdown").setup()
end

function Plugin.folke()
  vim.pack.add({
    "https://github.com/folke/which-key.nvim",
    "https://github.com/folke/snacks.nvim"
  }, { confirm = false })

  local wk = require("which-key")
  local snacks = require("snacks")

  wk.setup()
  snacks.setup(
    {
      input = {},   -- Enhances `ask()`
      picker = {    -- Enhances `select()`
        actions = {
          opencode_send = function(...) return require("opencode").snacks_picker_send(...) end,
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
  )
end

function Plugin.surround()
  vim.pack.add({
    "https://github.com/kylechui/nvim-surround"
  }, { confirm = false })
  local surround = require("nvim-surround")
  surround.setup()
end

function Plugin.autopairs()
  vim.pack.add({
    "https://github.com/windwp/nvim-autopairs"
  }, { confirm = false })
  require("nvim-autopairs").setup()
end

function M.setup()
  vim.pack.add({
    { src = "https://github.com/nvim-lua/plenary.nvim" }
  }, { confirm = false })

  for _, setup in pairs(Plugin) do
    setup()
  end
end

return M
