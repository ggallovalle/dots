# xdg
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export EDITOR=nvim
export BROWSER=zen-browser
export MANPAGER='nvim +Man!'
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/zsh/starship.toml"
export DOTFILES="${HOME}/dots"
export GHQ_ROOT="${HOME}/ghq"

typeset -U path
path+=( 
  "${XDG_CONFIG_HOME}/zsh/bin" 
  "${XDG_DATA_HOME}/nvim/mason/bin" 
  "${HOME}/.local/bin"
  "${XDG_DATA_HOME}/mise/shims"
)

# some programs read this
export QT_QPA_PLATFORMTHEME=gtk3
export EZA_STRICT=1

