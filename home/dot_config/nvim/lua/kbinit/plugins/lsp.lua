---@type LazyPluginSpec
local Conform = {
  url = "https://github.com/stevearc/conform.nvim",
  opts = function ()
    local conform = require("conform.util")
    local luafmt_cwd = conform.root_file({ "luafmt.toml", ".luafmt.toml" })
    local kdlfmt_cwd = conform.root_file({ "kdlfmt.kdl", ".kdlfmtignore" })
    return {
      formatters_by_ft = {
        kdl = { "kdlfmt" },
        lua = { "luafmt" },
        json = { lsp_format = "fallback" },
        zig = { lsp_format = "fallback" },
        python = { lsp_format = "fallback" }
      },
      formatters = {
        ---@type conform.FileFormatterConfig
        luafmt = {
          meta = {
            url = "https://github.com/EmmyLuaLs/emmylua-analyzer-rust/blob/main/docs/emmylua_formatter/tutorial_EN.md",
            description = "EmmyLuaLs formatter"
          },
          command = "luafmt",
          args = { "--stdin" },
          cwd = luafmt_cwd
        },
        ---@type conform.FileFormatterConfig
        kdlfmt = {
          meta = {
            url = "https://github.com/hougesen/kdlfmt",
            description = "a formatter for kdl documents."
          },
          command = "kdlfmt",
          args = { "format", "--kdl-version", "v1", "--stdin" },
          cwd = kdlfmt_cwd
        }
      }
    }
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
    ensure_installed = {
      "emmylua_ls",
      "vtsls",
      "vue_ls",
      "svelte",
      "gopls",
      "rust_analyzer",
      "zls",
      -- "pyright",
      "jsonls",
      "yamlls",
      "taplo",
      "tinymist",
      "just",
      "basedpyright",
      "ruff"
    }
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
      tree.install({
        -- general
        "markdown",
        "markdown_inline",
        "typst",
        "gitignore",
        "sql",
        --
        "rust",
        "zig",
        "swift",
        --
        "lua",
        --
        "python",
        -- javascript and web
        "javascript",
        "typescript",
        "jsx",
        "tsx",
        "vue",
        "css",
        "html",
        -- elixir
        "elixir",
        "eex",
        -- data transport
        "json",
        "kdl",
        "yaml",
        "xml",
        "csv",
        "toml",
        "hcl",
        -- terminal
        "bash",
        "fish",
        "zsh",
        "powershell",
        "dockerfile",
        "just"
      })
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
