source_dir := `pwd`

default:
  @just --list

[script]
apply:
  git ls-files --modified --others --exclude-standard -- 'home/**' |
    sed "s|^home/|{{source_dir}}/home/|" |
    xargs -r -I{} chezmoi apply --force --source-path {}

format-kdl:
  kdlfmt format --kdl-version v1 ./home/dot_config/niri
  kdlfmt format --kdl-version v2 ./home/dot_config/zsh/usage
  kdlfmt format --kdl-version v1 ./home/dot_config/zellij

format-lua:
    luafmt ./home/dot_config/nvim/lua --write
    luafmt ./home/dot_config/wezterm --write

format: format-kdl format-lua
  echo "done"
