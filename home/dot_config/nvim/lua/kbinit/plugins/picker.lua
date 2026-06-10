---@type LazyPluginSpec
local FFF = {
  url = "https://github.com/dmtrKovalenko/fff",
  build = function ()
    -- downloads a prebuilt binary or falls back to cargo build
    require("fff.download").download_or_build_binary()
  end,
  -- for nixos:
    -- build = "nix run .#release",
  opts = {
    debug = {
      enabled = false,
      show_scores = false
    },
    keymaps = {
      move_up = { "<Up>", "<C-p>", "<C-k>" },
      move_down = { "<Down>", "<C-n>", "<C-j>" }
    }
  },
  -- v0.9.2+ fixes home-dir init crash for find_files
  keys = {
    {
      "<leader>sf",
      function ()
        require("fff").find_files()
      end,
      desc = "[F]iles"
    },
    {
      "<leader>sg",
      function ()
        require("fff").live_grep({
          grep = {
            modes = { "fuzzy", "plain" }
          }
        })
      end,
      desc = "[F]uzzy grep"
    },
    {
      "<leader>sw",
      function ()
        require("fff").live_grep({ query = vim.fn.expand("<cword>") })
      end,
      desc = "[W]ord"
    }
  }
}

---@type LazyPluginSpec
local Snacks = {
  url = "https://github.com/folke/snacks.nvim.git",
  lazy = false,
  ---@type snacks.Config
  opts = {},
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
      "<leader>gL",
      function ()
        require("snacks")
          .lazygit
          .open()
      end,
      desc = "[L]azygit"
    },
    {
      "<leader>gl",
      function ()
        require("snacks")
          .lazygit
          .log_file()
      end,
      desc = "[L]og"
    }
  }
}

return { FFF, Snacks }
