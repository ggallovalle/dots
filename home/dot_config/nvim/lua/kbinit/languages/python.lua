return {
  lsp = {
    basedpyright = true,
    ruff = true
  },
  mason = { "basedpyright", "ruff" },
  treesitter = { "python" },
  conform = {
    formatters_by_ft = {
      python = { lsp_format = "fallback" }
    }
  }
}