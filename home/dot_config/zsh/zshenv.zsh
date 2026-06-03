0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# xdg
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

# default programs
export EDITOR=nvim
export BROWSER=zen-browser
export MANPAGER='nvim +Man!'
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/zsh/starship.toml"
export DOTFILES="${HOME}/dots"
export GHQ_ROOT="${HOME}/ghq"

# path
typeset -U path
path+=( 
  "${XDG_CONFIG_HOME}/zsh/bin" 
  "${XDG_DATA_HOME}/nvim/mason/bin" 
  "${HOME}/.local/bin"
)


# secrets
if [[ -o interactive ]] && command -v secret-tool >/dev/null 2>&1; then
  local secret_value
  secret_value="$(secret-tool lookup service bitwarden name session 2>/dev/null)" && [[ -n $secret_value ]] && export BW_SESSION="$secret_value"
  # export GITHUB_TOKEN="$(secret-tool lookup service github name api_key)"
  secret_value="$(secret-tool lookup service jellyfin name user 2>/dev/null)" && [[ -n $secret_value ]] && export KB_JELLYFIN_USER="$secret_value"
  secret_value="$(secret-tool lookup service jellyfin name password 2>/dev/null)" && [[ -n $secret_value ]] && export KB_JELLYFIN_PASSWORD="$secret_value"
  secret_value="$(secret-tool lookup service jellyfin name server 2>/dev/null)" && [[ -n $secret_value ]] && export KB_JELLYFIN_SERVER="$secret_value"
  secret_value="$(secret-tool lookup service jellyfin name api.token 2>/dev/null)" && [[ -n $secret_value ]] && export KB_JELLYFIN_TOKEN="$secret_value"
fi

# some programs read this
export QT_QPA_PLATFORMTHEME=gtk3
export EZA_STRICT=1

# private
typeset -gA kbroom
kbroom[ZDOTDIR]="${0:h}"
# printf '%s => %s\n' "${(@kv)kbroom}"
