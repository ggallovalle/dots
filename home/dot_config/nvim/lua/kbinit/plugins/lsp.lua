---@type LazyPluginSpec
local BlinkLib = { url = "https://github.com/saghen/blink.lib.git" }

local HBlink = {}
function HBlink.select_and_accept()
    local cmp = require("blink.cmp")
    return cmp.select_and_accept({
        callback = function()
            cmp.show_signature()
            cmp.show_documentation()
        end
    })
end

function HBlink.tab()
    local cmp = require("blink.cmp")
    if cmp.snippet_active() then
        return cmp.accept()
    end
    return HBlink.select_and_accept()
end

---@type LazyPluginSpec
local FileMention = {
    url = "https://github.com/not-manu/filemention.nvim",
    event = "InsertEnter",
    opts = {
        finder = "fff",
  filetypes = { "markdown", "text", "gitcommit", "typst" },  -- or "*" if you live dangerously
    }
}

---@type LazyPluginSpec
local FFF = {
    "dmtrKovalenko/fff.nvim",
    build = function()
        -- downloads a prebuilt binary or falls back to cargo build
        require("fff.download").download_or_build_binary()
    end,
    -- for nixos:
  -- build = "nix run .#release",
    opts = {
        debug = {
            enabled = true,
            show_scores = true
        }
    },
    lazy = false, -- the plugin lazy-initialises itself
    keys = {
        {
            "<leader>sf",
            function()
                require("fff").find_files()
            end,
            desc = "[F]iles"
        },
        {
            "<leader>sg",
            function()
                require("fff").live_grep()
            end,
            desc = "[G]rep"
        },
        {
            "<leader>sz",
            function()
                require("fff").live_grep({ grep = { modes = { "fuzzy", "plain" } } })
            end,
            desc = "[F]uzzy grep"
        },
        {
            "<leader>sw",
            function()
                require("fff").live_grep({ query = vim.fn.expand("<cword>") })
            end,
            desc = "[W]ord"
        }
    }
}

---@type LazyPluginSpec
local BlinkCmp = {
    url = "https://github.com/saghen/blink.cmp.git",
    dependencies = {
        BlinkLib
    },
    build = function()
        require("blink.cmp").build():wait(60000)
    end,
    ---@diagnostic disable-next-line: missing-fields
  ---@type blink.cmp.ConfigStrict
    opts = {
        ---@diagnostic disable-next-line: missing-fields
        sources = {
            default = { "filemention", "lsp", "path", "snippets", "buffer" },
            providers = {
                filemention = {
                    name = "filemention",
                    module = "filemention.sources.blink"
                }
            }
        },
        keymap = {
            preset = "default",
            ["<C-y>"] = { HBlink.select_and_accept, "fallback" },
            ["<CR>"] = { HBlink.select_and_accept, "fallback" },
            ["<Tab>"] = { HBlink.tab, "snippet_forward", "fallback" },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },
            ["<C-j>"] = { "select_next", "fallback_to_mappings" },
            ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
            ["<C-d>"] = { "scroll_documentation_down" },
            ["<C-u>"] = { "scroll_documentation_up" },
            ["<C-h>"] = { "show_signature", "hide_signature", "fallback" }
        }
    }
}

---@type LazyPluginSpec
local Mason = { url = "https://github.com/williamboman/mason.nvim.git", config = true }

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

return { BlinkCmp, Mason, NvimLspconfig, MasonLspconfig, Treesitter, FileMention, FFF }
