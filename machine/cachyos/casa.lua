
return {
  entries = {
    {
      type = "directory",
      source = { "zsh", "config", "zsh" },
      target = { ".config", "zsh" }
    },
    {
      type = "file",
      source = { "zsh", "home", "zshrc" },
      target = { ".zshrc" }
    },
    {
      type = "file",
      source = { "zsh", "home", "zshenv" },
      target = { ".zshenv" }
    },
  }
}
