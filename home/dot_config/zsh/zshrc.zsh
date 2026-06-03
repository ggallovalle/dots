0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"


zmodload zsh/param/private
zmodload zsh/zutil

source ~/.zi/evaled/mise.zsh

fpath+=( ${0:h}/functions ${0:h}/completions )
autoload -Uz ${0:h}/functions/*(.:t)


source ${0:h}/zinit.zsh
source ${0:h}/alias.zsh

# j - jump [arg]
# ji - jump interactive
if (( ${+commands[zoxide]} )); then
  source ~/.zi/evaled/zoxide.zsh
fi
if [[ -o interactive && ${TERM:-} != dumb ]]; then
  if (( ${+commands[starship]} )); then
    source ~/.zi/evaled/starship.zsh
  fi
fi

