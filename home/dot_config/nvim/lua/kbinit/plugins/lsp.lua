---@type LazyPluginSpec
local BlinkLib = {
  url = "https://github.com/saghen/blink.lib.git",
}

---@type LazyPluginSpec
local BlinkCmp = {
  url = "https://github.com/saghen/blink.cmp.git",
  dependencies = {
    BlinkLib,
  },
  build = function()
    require("blink.cmp").build():wait(60000)
  end,
  opts = function()
    ---@type blink.cmp.ConfigStrict
    local opts = {
      keymap = {
        preset = "default",
        ["<C-y>"] = { "fallback" },
        ["<CR>"] = { "fallback" },
        ["<Tab>"] = { "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
        ["<C-j>"] = { "select_next", "fallback_to_mappings" },
        ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-d>"] = { "scroll_documentation_down" },
        ["<C-u>"] = { "scroll_documentation_up" },
        ["<C-h>"] = { "show_signature", "hide_signature", "fallback" },
      },
    }
    return opts
  end,
  config = function(_, opts)
    local cmp = require("blink.cmp")

    local select_and_accept = function()
      return cmp.select_and_accept({
        callback = function()
          cmp.show_signature()
          cmp.show_documentation()
        end,
      })
    end

    opts.keymap["<C-y>"] = { select_and_accept, "fallback" }
    opts.keymap["<CR>"] = { select_and_accept, "fallback" }
    opts.keymap["<Tab>"] = {
      function()
        if cmp.snippet_active() then
          return cmp.accept()
        end

        return select_and_accept()
      end,
      "snippet_forward",
      "fallback",
    }

    cmp.setup(opts)
  end,
}

---@type LazyPluginSpec
local Mason = {
  url = "https://github.com/williamboman/mason.nvim.git",
  config = true,
}

---@type LazyPluginSpec
local NvimLspconfig = {
  url = "https://github.com/neovim/nvim-lspconfig.git",
}

---@type LazyPluginSpec
local MasonLspconfig = {
  url = "https://github.com/williamboman/mason-lspconfig.nvim.git",
  dependencies = {
    Mason,
    NvimLspconfig,
  },
  opts = function()
    ---@type MasonLspconfigSettings
    local opts = {
      automatic_enable = true,
      ensure_installed = {
        "emmylua_ls",
        "vtsls",
        "vue_ls",
        "svelte",
        "gopls",
        "rust_analyzer",
        "zls",
        "pyright",
        "jsonls",
        "yamlls",
        "taplo",
        "tinymist",
      },
    }
    return opts
  end,
  config = function(_, opts)
    local setup = function()
      require("mason-lspconfig").setup(opts)
    end

    if vim.v.vim_did_enter == 1 and #vim.api.nvim_list_uis() > 0 then
      setup()
      return
    end

    vim.api.nvim_create_autocmd("UIEnter", {
      once = true,
      callback = setup,
    })
  end,
}

---@type LazyPluginSpec
local Treesitter = {
  url = "https://github.com/nvim-treesitter/nvim-treesitter.git",
  build = ":TSUpdate",
  opts = function()
    ---@type TSConfig
    local opts = {}
    return opts
  end,
  config = function(_, opts)
    local setup = function()
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
        "just",
      })
    end

    if vim.v.vim_did_enter == 1 and #vim.api.nvim_list_uis() > 0 then
      setup()
      return
    end

    vim.api.nvim_create_autocmd("UIEnter", {
      once = true,
      callback = setup,
    })
  end,
}

return {
  BlinkCmp,
  Mason,
  NvimLspconfig,
  MasonLspconfig,
  Treesitter,
}
