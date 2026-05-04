0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# xdg
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# default programs
export EDITOR=nvim

# path
typeset -U path
path+=( $HOME/.config/zsh/bin, "${XDG_DATA_HOME}/nvim/mason/bin" )

# dark mode
export QT_QPA_PLATFORMTHEME=gtk3

# secrets
export BW_SESSION="$(secret-tool lookup service bitwarden name session)"
export GITHUB_TOKEN="$(secret-tool lookup service github name api_key)"

# private
typeset -gA kbroom
kbroom[ZDOTDIR]="${0:h}"
# printf '%s => %s\n' "${(@kv)kbroom}"
