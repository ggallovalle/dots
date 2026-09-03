local Vue = {
  lsp = {
    vtsls = function ()
      local xdg = require("std.xdg")
      local vue_path = xdg.data:join("mason", "packages", "vue-language-server", "node_modules", "@vue", "language-server")

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
        init_options = { hostInfo = "neovim" },
        settings = {
          vtsls = {
            tsserver = {
              globalPlugins = {
                {
                  name = "@vue/typescript-plugin",
                  location = tostring(vue_path),
                  languages = { "vue" },
                  configNamespace = "typescript"
                }
              }
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
        vue = { hybridMode = true }
      }
    }
  },
  mason = { "vtsls", "vue_ls" },
  treesitter = {
    "vue",
  },
  conform = {
    formatters_by_ft = {
      vue = { "biome" }
    }
  }
}

local Svelte = {
  lsp = {
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
  mason = { "svelte" },
  treesitter = { "svelte" }
}

local Typescript = {
  lsp = {
    tsc = true
  },
  treesitter = {
    "typescript",
    "javascript",
    "jsx",
    "tsx",
    "css",
    "html"
  },
  mason = { "tsc", "biome" },
  conform = {
    formatters_by_ft = {
      javascript = { "biome" },
      javascriptreact = { "biome" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
      css = { "biome" }
    }
  }
}

return { Vue, Svelte, Typescript }
