0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"


zmodload zsh/param/private
zmodload zsh/zutil

# source ~/.zi/evaled/mise.zsh

fpath+=( ${0:h}/functions ${0:h}/completions )
autoload -Uz ${0:h}/functions/*(.:t)


if [[ -o interactive ]]; then
  source ${0:h}/zinit.zsh
  source ${0:h}/alias.zsh
  source ${0:h}/keymap.zsh

  source ~/.zi/evaled/zoxide.zsh
  source ~/.zi/evaled/wt.zsh
  source ~/.zi/evaled/starship.zsh
fi

