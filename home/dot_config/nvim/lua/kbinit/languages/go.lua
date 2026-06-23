return {
  lsp = {
    gopls = {
      filetypes = { "go" },
      root_markers = { "go.mod", ".git" },
      settings = {
        gopls = {
          analyses = { unusedparams = true },
          staticcheck = true
        }
      }
    }
  },
  mason = { "gopls" },
  treesitter = { "go" }
}