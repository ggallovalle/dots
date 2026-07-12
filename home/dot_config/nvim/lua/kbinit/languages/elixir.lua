return {
  lsp = {
    elixirls = {
      filetypes = { "elixir", "eelixir", "heex" },
      root_markers = { "mix.exs", ".git" },
      settings = {
        elixirls = {
          dialyzerEnabled = false,
          enableTestLenses = false
        }
      }
    }
  },
  mason = { "elixirls" },
  treesitter = {
    "elixir",
    "eex",
    "heex"
  },
  conform = {
    formatters_by_ft = {
      elixir = { "mix" },
      heex = { "mix" }
    }
  }
}