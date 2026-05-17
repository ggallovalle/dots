local xdg = require("std.xdg")

local M = {}

local H = {}

function H.diagnostic()
    vim.diagnostic.config({
        severity_sort = true,
        update_in_insert = false,
        float = { source = "if_many" }
    })
end

function H.lsp_config()
    vim.lsp.config("emmylua_ls", {
        root_markers = { ".emmyrc.json" }
    })

    local mason_path = xdg.data:join("mason", "packages")

    local vue_path = mason_path:join(
        "vue-language-server", "node_modules", "@vue", "language-server"
    )

    local vue_plugin = {
        name = "@vue/typescript-plugin",
        location = tostring(vue_path),
        languages = { "vue" },
        configNamespace = "typescript"
    }

    vim.lsp.config("vtsls", {
        cmd = { "vtsls", "--stdio" },
        filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
        root_markers = { "tsconfig.json", "jsconfig.json", "package.json", "bunfig.toml", ".git" },
        init_options = {
            hostInfo = "neovim"
        },
        settings = {
            vtsls = {
                tsserver = {
                    globalPlugins = { vue_plugin }
                }
            }
        }
    })

    vim.lsp.config("vue_ls", {
        cmd = { "vue-language-server", "--stdio" },
        filetypes = { "vue" },
        root_markers = { "package.json", ".git" },
        init_options = {
            vue = {
                hybridMode = true
            }
        }
    })

    vim.lsp.config("svelte", {
        cmd = { "svelteserver", "--stdio" },
        filetypes = { "svelte" },
        root_markers = { "package.json", ".git" },
        settings = {
            typescript = {
                inlayHints = {
                    enumMemberValues = { enabled = true },
                    functionLikeReturnTypes = { enabled = true },
                    parameterNames = {
                        enabled = "literals",
                        suppressWhenArgumentMatchesName = true
                    },
                    parameterTypes = { enabled = true },
                    propertyDeclarationTypes = { enabled = true },
                    variableTypes = { enabled = true }
                }
            }
        }
    })

    vim.lsp.config("gopls", {
        filetypes = { "go" },
        root_markers = { "go.mod", ".git" },
        settings = {
            gopls = {
                analyses = { unusedparams = true },
                staticcheck = true
            }
        }
    })

    vim.lsp.config("rust_analyzer", {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        root_markers = { "Cargo.toml", ".git" }
    })

    vim.lsp.config("pyright", {
        cmd = { "pyright-langserver", "--stdio" },
        filetypes = { "python" },
        root_markers = { "pyproject.toml", "setup.py", ".git" },
        settings = {
            python = {
                analysis = {
                    typeCheckingMode = "standard"
                }
            }
        }
    })

    vim.lsp.config("jsonls", {
        filetypes = { "json", "jsonc" },
        root_markers = { "package.json", "tsconfig.json", ".git" },
        settings = {
            json = {
                format = { enabled = true },
                validate = { enabled = true }
            }
        }
    })

    vim.lsp.config("yamlls", {
        filetypes = { "yaml", "yml" },
        root_markers = { ".yaml", ".yml", ".git" },
        settings = {
            yaml = {
                format = { enabled = true },
                validate = true,
                hover = true,
                completion = true
            }
        }
    })

    vim.lsp.config("taplo", {
        filetypes = { "toml" },
        root_markers = { "taplo.toml", ".taplo.toml", "pyproject.toml", "Cargo.toml", ".git" },
        settings = {
            evenBetterToml = {
                schema = {
                    enabled = true,
                    -- associations = {
                    --     ["config.toml"] = "https://developers.openai.com/codex/config-schema.json"
                    -- }
                }
            }
        }
    })

    vim.lsp.config("tinymist", {
        cmd = { "tinymist" },
        filetypes = { "typst" },
        root_markers = { ".git" }
    })
end

function H.lsp_keymaps()
    ---@type string
    local completion = vim.g.completion_mode or "blink" -- or 'native' for built-in completion
    vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
            local bufnr = args.buf
            local client = vim.lsp.get_client_by_id(args.data.client_id)
            if client == nil then
                return
            end
            if client.server_capabilities == nil then
                return
            end

            if completion == "native" and client:supports_method("textDocument/completion") then
                vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })
            end

            if client:supports_method("textDocument/inlayHint") then
                vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end

            if client:supports_method("textDocument/documentColor") then
                vim.lsp.document_color.enable(true, { bufnr = bufnr }, { style = "virtual" })
            end

            require("kbinit.keymap").on_lsp_attach(bufnr, client, client.server_capabilities)
        end
    })
end

function H.mason()
    vim.pack.add({
        { src = "https://github.com/williamboman/mason.nvim" },
        { src = "https://github.com/williamboman/mason-lspconfig.nvim" },
        { src = "https://github.com/neovim/nvim-lspconfig" }
    }, { confirm = false })

    require("mason").setup()
    require("mason-lspconfig").setup({
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
            "tinymist"
        }
    })
end

function H.treesitter()
    vim.pack.add({ { src = "https://github.com/nvim-treesitter/nvim-treesitter" } }, {
        confirm = false
    })

    vim.api.nvim_create_autocmd("PackChanged", {
        pattern = "nvim-treesitter",
        callback = function()
            vim.cmd.TSUpdate()
        end
    })

    local tree = require("nvim-treesitter")
    tree.setup()
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

function H.cmp()
    vim.pack.add({
        "https://github.com/saghen/blink.lib",
        "https://github.com/saghen/blink.cmp"
    }, { confirm = false })
    local cmp = require("blink.cmp")
    cmp.build():wait(60000)
    local select_and_accept = function()
        return cmp.select_and_accept({
            callback = function()
                cmp.show_signature()
                cmp.show_documentation()
            end
        })
    end
    cmp.setup({
        keymap = {
            ---@diagnostic disable-next-line: param-type-mismatch
            preset = "default",
            ["<C-y>"] = { select_and_accept, "fallback" },
            ["<CR>"] = { select_and_accept, "fallback" },
            ["<Tab>"] = {
                function()
                    if cmp.snippet_active() then
                        return cmp.accept()
                    else
                        return select_and_accept()
                    end
                end,
                "snippet_forward",
                "fallback"
            },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },
            ["<C-j>"] = { "select_next", "fallback_to_mappings" },
            ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
            ["<C-d>"] = { "scroll_documentation_down" },
            ["<C-u>"] = { "scroll_documentation_up" },
            ["<C-h>"] = { "show_signature", "hide_signature", "fallback" }
        }
    })
end

function M.setup()
    H.diagnostic()
    H.lsp_config()
    H.lsp_keymaps()
    H.cmp()
    H.mason()
    H.treesitter()
end

return M
