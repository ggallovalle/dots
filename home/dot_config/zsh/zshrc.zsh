0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"


zmodload zsh/param/private
zmodload zsh/zutil

eval "$(mise activate zsh)"


fpath+=( ${0:h}/functions ${0:h}/completions )
autoload -Uz ${0:h}/functions/*(.:t)


source ${0:h}/zinit.zsh
source ${0:h}/alias.zsh

# j - jump [arg]
# ji - jump interactive
eval "$(zoxide init zsh --cmd j)"
if [[ -o interactive ]]; then
  eval "$(starship init zsh)"
fi
eval "$(wt config shell init zsh)"
eval "$(tv init zsh)"
