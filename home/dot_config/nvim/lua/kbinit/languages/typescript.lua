return {
  lsp = {
    vtsls = function ()
      local xdg = require("std.xdg")
      local mason_path = xdg.data:join("mason", "packages")
      local vue_path = mason_path:join("vue-language-server", "node_modules", "@vue", "language-server")

      local vue_plugin = {
        name = "@vue/typescript-plugin",
        location = tostring(vue_path),
        languages = { "vue" },
        configNamespace = "typescript"
      }

      return {
        cmd = { "vtsls", "--stdio" },
        filetypes = {
          "typescript",
          "javascript",
          "javascriptreact",
          "typescriptreact",
          "vue"
        },
        root_markers = {
          "tsconfig.json",
          "jsconfig.json",
          "package.json",
          "bunfig.toml",
          ".git"
        },
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
      }
    end,
    vue_ls = {
      cmd = { "vue-language-server", "--stdio" },
      filetypes = { "vue" },
      root_markers = { "package.json", ".git" },
      init_options = {
        vue = {
          hybridMode = true
        }
      }
    },
    svelte = {
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
    }
  },
  mason = {
    "vtsls",
    "vue_ls",
    "svelte"
  },
  treesitter = {
    "javascript",
    "typescript",
    "jsx",
    "tsx",
    "vue",
    "css",
    "html"
  }
}