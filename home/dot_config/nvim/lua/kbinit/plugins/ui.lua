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
  config = function (_spec, opts)
    local wk = require("which-key")
    wk.setup(opts)
    wk.add({
      ---@diagnostic disable-next-line: assign-type-mismatch
      { "gr", group = "[G]o to LSP" },
      ---@diagnostic disable-next-line: assign-type-mismatch
      { "<leader>c", group = "[C]ode" },
      { "<leader>i", group = "[I]nsert" },
      { "<leader>it", group = "[T]ime", icon = "󰥔" },
      { "<leader>f", group = "[F]ile" },
      { "<leader>g", group = "[G]it" },
      { "<leader>a", group = "[A]I" },
      { "<leader>s", group = "[S]earch" },
      { "<leader>d", group = "[D]ocument" },
      { "grn", desc = "Re[n]ame" },
      { "gra", desc = "Code [A]ction" },
      { "grx", desc = "Code [X]Lens" },
      { "grr", desc = "[R]eferences" },
      { "gri", desc = "[I]mplementation" },
      { "grt", desc = "[T]ype Definition" }
    })
  end
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
    open_cmd = "zen-browser %s"
  }
}

return {
  Screenkey, Devicons, Catppuccin, WhichKey, RenderMarkdown, TypstPreview
}
