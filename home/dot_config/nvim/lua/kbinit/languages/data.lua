return {
  lsp = {
    jsonls = function ()
      return {
        filetypes = { "json", "jsonc" },
        root_markers = { "package.json", "tsconfig.json", ".git" },
        settings = {
          json = {
            format = { enable = true },
            validate = { enable = true },
            schemas = require("schemastore").json.schemas()
          }
        }
      }
    end,
    yamlls = {
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
    },
    taplo = {
      filetypes = { "toml" },
      root_markers = {
        "taplo.toml",
        ".taplo.toml",
        "pyproject.toml",
        "Cargo.toml",
        "mise.toml",
        ".git"
      },
      settings = {
        -- https://github.com/tamasfe/taplo/blob/b673b44df2773db8673a00df2e7654b769f7fde7/editors/vscode/package.json#L160
        evenBetterToml = {
          schema = {
            enabled = true,
            associations = {
              ["mise.toml"] = "https://mise.en.dev/schema/mise.json",
              ["mise.local.toml"] = "https://mise.en.dev/schema/mise.json"
            }
          }
        }
      }
    }
  },
  mason = { "jsonls", "yamlls", "taplo" },
  treesitter = {
    "json",
    "yaml",
    "toml",
    "kdl",
    "xml",
    "csv",
    "hcl"
  },
  conform = function ()
    local conform = require("conform.util")
    local kdlfmt_cwd = conform.root_file({ "kdlfmt.kdl", ".kdlfmtignore" })

    return {
      formatters_by_ft = {
        kdl = { "kdlfmt" },
        json = { lsp_format = "fallback" }
      },
      formatters = {
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
  end
}
