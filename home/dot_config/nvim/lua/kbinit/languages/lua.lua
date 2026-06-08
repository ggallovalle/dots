return {
  lsp = {
    ["emmylua_ls"] = true
  },
  mason = {
    "emmylua_ls"
  },
  treesitter = {
    "lua"
  },
  conform = function ()
    local conform = require("conform.util")

    local luafmt_cwd = conform.root_file({ "luafmt.toml", ".luafmt.toml" })

    return {
      formatters_by_ft = {
        lua = { "luafmt" }
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
        }
      }
    }
  end
}
