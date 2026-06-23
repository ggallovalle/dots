---@type LazyPluginSpec
local Conform = {
  url = "https://github.com/stevearc/conform.nvim",
  opts = function ()
    local languages = require("kbinit.languages")
    return languages.get_conform_config()
  end,
  keys = {
    {
      "<leader>df",
      function ()
        require("conform").format({})
      end,
      desc = "[D]ocument [F]ormat"
    }
  }
}

---@type LazyPluginSpec
local Mason = {
  url = "https://github.com/williamboman/mason.nvim.git",
  config = true
}

---@type LazyPluginSpec
local NvimLspconfig = { url = "https://github.com/neovim/nvim-lspconfig.git" }

---@type LazyPluginSpec
local MasonLspconfig = {
  url = "https://github.com/williamboman/mason-lspconfig.nvim.git",
  dependencies = {
    Mason,
    NvimLspconfig
  },
  ---@type MasonLspconfigSettings
  opts = {
    automatic_enable = true,
    ensure_installed = require("kbinit.languages").get_mason_ensure_installed()
  }
}

---@type LazyPluginSpec
local Treesitter = {
  url = "https://github.com/nvim-treesitter/nvim-treesitter.git",
  build = ":TSUpdate",
  ---@type TSConfig
  ---@diagnostic disable-next-line: missing-fields
  opts = {},
  config = function (_, opts)
    local setup = function ()
      local tree = require("nvim-treesitter")

      tree.setup(opts)
      tree.install(require("kbinit.languages").get_treesitter_parsers())
    end

    if vim.v.vim_did_enter == 1 and #vim.api.nvim_list_uis() > 0 then
      setup()
      return
    end

    vim.api.nvim_create_autocmd("UIEnter", {
      once = true,
      callback = setup
    })
  end
}

return { Mason, NvimLspconfig, MasonLspconfig, Treesitter, Conform }
