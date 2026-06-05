default:
  @just --list

format-kdl:
  kdlfmt format --kdl-version v1 ./home/dot_config/niri
  kdlfmt format --kdl-version v2 ./home/dot_config/zsh/usage
  kdlfmt format --kdl-version v1 ./home/dot_config/zellij

format-lua:
    luafmt ./home/dot_config/nvim/lua --write
    luafmt ./home/dot_config/wezterm --write

format: format-kdl format-lua
  echo "done"


