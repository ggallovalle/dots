0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# secrets
if [[ -o interactive ]] && (( ${+commands[secret-tool]} )); then
  local secret_value
  secret_value="$(secret-tool lookup service bitwarden name session 2>/dev/null)" && [[ -n $secret_value ]] && export BW_SESSION="$secret_value"
  # export GITHUB_TOKEN="$(secret-tool lookup service github name api_key)"
  secret_value="$(secret-tool lookup service jellyfin name user 2>/dev/null)" && [[ -n $secret_value ]] && export KB_JELLYFIN_USER="$secret_value"
  secret_value="$(secret-tool lookup service jellyfin name password 2>/dev/null)" && [[ -n $secret_value ]] && export KB_JELLYFIN_PASSWORD="$secret_value"
  secret_value="$(secret-tool lookup service jellyfin name server 2>/dev/null)" && [[ -n $secret_value ]] && export KB_JELLYFIN_SERVER="$secret_value"
  secret_value="$(secret-tool lookup service jellyfin name api.token 2>/dev/null)" && [[ -n $secret_value ]] && export KB_JELLYFIN_TOKEN="$secret_value"
fi

# private
typeset -gA kbroom
kbroom[ZDOTDIR]="${0:h}"
# printf '%s => %s\n' "${(@kv)kbroom}"
