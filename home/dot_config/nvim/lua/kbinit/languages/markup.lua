return {
  lsp = {
    tinymist = {
      cmd = { "tinymist" },
      filetypes = { "typst" },
      root_markers = { ".git" }
    }
  },
  mason = { "tinymist" },
  treesitter = {
    "typst",
    "markdown",
    "markdown_inline"
  }
}