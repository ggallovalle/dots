local H = {}

function H.entry_config_dir(program, attributes)
  local entry = {
    type = "directory",
    source = { program, "config", program },
    target = { ".config", program }
  }
  if type(attributes) == "table" then
    entry.attributes = attributes
  end

  return entry
end

function H.entry_home_file(program, source, target, attributes)
  local entry = {
    type = "file",
    source = { program, "home", source },
    target = { target or source }
  }
  if type(attributes) == "table" then
    entry.attributes = attributes
  end

  return entry
end

function H.entry_config_file(program, source, target, attributes)
  local entry = {
    type = "file",
    source = { program, "config", program, source },
    target = { ".config", program, target or source }
  }
  if type(attributes) == "table" then
    entry.attributes = attributes
  end

  return entry
end

return {
  entries = {
    -- zsh
    H.entry_config_dir("zsh"),
    H.entry_home_file("zsh", "zshrc", ".zshrc"),
    H.entry_home_file("zsh", "zshenv", ".zshenv"),
    -- git
    H.entry_config_file("git", "config", nil, { "template" }),
    -- mise
    H.entry_config_dir("mise"),
    -- nvim
    H.entry_config_dir("nvim"),
    -- gui
    -- niri
    H.entry_config_dir("niri"),
    H.entry_config_dir("noctalia"),
  }
}
