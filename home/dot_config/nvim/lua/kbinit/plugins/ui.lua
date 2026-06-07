---@type LazyPluginSpec
local Screenkey = {
  url = "https://github.com/NStefan002/screenkey.nvim.git",
  ---@type screenkey.config
  ---@diagnostic disable-next-line: missing-fields
  opts = {
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
  }
}

---@type LazyPluginSpec
local Devicons = {
  url = "https://github.com/nvim-tree/nvim-web-devicons.git",
  opts = {
    variant = "dark"
  }
}

---@type LazyPluginSpec
local Catppuccin = {
  url = "https://github.com/catppuccin/nvim.git",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  ---@type CatppuccinOptions
  opts = {
    flavour = "mocha"
  }
}

---@type LazyPluginSpec
local WhichKey = {
  url = "https://github.com/folke/which-key.nvim.git",
  config = true
}

---@type LazyPluginSpec
local Snacks = {
  url = "https://github.com/folke/snacks.nvim.git",
  lazy = true,
  ---@type snacks.Config
  opts = {
    input = {},
    picker = {
      actions = {
        opencode_send = function (...)
          return require("opencode").snacks_picker_send(...)
        end
      },
      win = {
        input = {
          keys = {
            ["<a-a>"] = { "opencode_send", mode = { "n", "i" } }
          }
        }
      }
    }
  },
  keys = {
    {
      "<leader>fe",
      function ()
        require("snacks")
          .explorer
          .open()
      end,
      desc = "[E]xplorer"
    },

    {
      "<leader>s:",
      function ()
        require("snacks")
          .picker
          .command_history()
      end,
      desc = "[C]ommand History"
    },
    {
      "<leader>sk",
      function ()
        require("snacks")
          .picker
          .keymaps()
      end,
      desc = "[K]eymaps"
    },
    {
      "<leader>sb",
      function ()
        local snacks = require("snacks")

        snacks.picker.buffers({
          confirm = function (picker, item)
            picker:close()
            if item then
              for _, win in ipairs(vim.api.nvim_list_wins()) do
                if vim.api.nvim_win_get_buf(win) == item.buf then
                  vim.api.nvim_set_current_win(win)
                  return
                end
              end
              vim.cmd.buffer({ bang = true, count = item.buf })
            end
          end,
          win = {
            list = {
              keys = {
                ["dd"] = "bufdelete"
              }
            }
          }
        })
      end,
      desc = "[B]uffers"
    },
    {
      "grs",
      function ()
        require("snacks")
          .picker
          .lsp_symbols()
      end,
      desc = "[S]ymbols"
    },
    {
      "<leader>gl",
      function ()
        require("snacks")
          .lazygit
          .open()
      end,
      desc = "[L]azygit"
    }
  }
}

---@type LazyPluginSpec
local RenderMarkdown = {
  url = "https://github.com/MeanderingProgrammer/render-markdown.nvim.git",
  config = true
}

---@type LazyPluginSpec
local TypstPreview = {
  url = "https://github.com/chomosuke/typst-preview.nvim.git",
  ---@type kbinit.typst.Config
  opts = {
    dependencies_bin = {
      tinymist = "tinymist",
      websocat = "websocat"
    },
    open_cmd = "firefox %s"
  }
}

return {
  Screenkey, Devicons, Catppuccin, WhichKey, Snacks, RenderMarkdown,
  TypstPreview
}
