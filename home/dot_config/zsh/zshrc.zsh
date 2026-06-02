0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"


zmodload zsh/param/private
zmodload zsh/zutil


fpath+=( ${0:h}/functions ${0:h}/completions )
autoload -Uz ${0:h}/functions/*(.:t)


source ${0:h}/zinit.zsh
source ${0:h}/alias.zsh

# j - jump [arg]
# ji - jump interactive
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd j)"
fi
if [[ -o interactive && ${TERM:-} != dumb ]]; then
  if command -v starship >/dev/null 2>&1; then
    eval "$(starship init zsh)"
  fi
fi

