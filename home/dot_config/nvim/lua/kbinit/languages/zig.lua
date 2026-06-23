return {
  lsp = {
    zls = true
  },
  mason = { "zls" },
  treesitter = { "zig" },
  conform = {
    formatters_by_ft = {
      zig = { lsp_format = "fallback" }
    }
  }
}