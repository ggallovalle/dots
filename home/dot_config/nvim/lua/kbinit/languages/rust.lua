return {
  lsp = {
    rust_analyzer = {
      cmd = { "rust-analyzer" },
      filetypes = { "rust" },
      root_markers = { "Cargo.toml", ".git" }
    }
  },
  mason = { "rust_analyzer" },
  treesitter = { "rust" },
  conform = {
    formatters_by_ft = {
      rust = { lsp_format = "fallback" }
    }
  }
}