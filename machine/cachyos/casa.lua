return {
  entries = {
    -- zsh
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
    -- git
    {
      type = "file",
      source = { "git", "config", "git", "config" },
      target = { ".config", "git", "config" },
      attributes = { "template" }
    },
  }
}
