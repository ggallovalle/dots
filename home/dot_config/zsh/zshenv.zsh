0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# xdg
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# default programs
export EDITOR=nvim
export BROWSER=firefox

# path
typeset -U path
path+=( 
  "${XDG_CONFIG_HOME}/zsh/bin" 
  "${XDG_DATA_HOME}/nvim/mason/bin" 
  "${HOME}/.local/bin"
)


# secrets
export BW_SESSION="$(secret-tool lookup service bitwarden name session)"
# export GITHUB_TOKEN="$(secret-tool lookup service github name api_key)"
export KB_JELLYFIN_USER="$(secret-tool lookup service jellyfin name user)"
export KB_JELLYFIN_PASSWORD="$(secret-tool lookup service jellyfin name password)"
export KB_JELLYFIN_SERVER="$(secret-tool lookup service jellyfin name server)"
export KB_JELLYFIN_TOKEN="$(secret-tool lookup service jellyfin name api.token)"

# some programs read this
export QT_QPA_PLATFORMTHEME=gtk3
export EZA_STRICT=1

# private
typeset -gA kbroom
kbroom[ZDOTDIR]="${0:h}"
# printf '%s => %s\n' "${(@kv)kbroom}"
