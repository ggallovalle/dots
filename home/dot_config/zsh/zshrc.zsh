0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"


zmodload zsh/param/private
zmodload zsh/zutil

source ~/.zi/evaled/mise.zsh

fpath+=( ${0:h}/functions ${0:h}/completions "${XDG_DATA_HOME}/zsh/site-functions"  )
autoload -Uz ${0:h}/functions/*(.:t)


if [[ -o interactive ]]; then
  if [[ -n "$KITTY_INSTALLATION_DIR" ]]; then
    export KITTY_SHELL_INTEGRATION="enabled"
    autoload -Uz -- "$KITTY_INSTALLATION_DIR"/shell-integration/zsh/kitty-integration
    kitty-integration
    unfunction kitty-integration
  fi

  source ${0:h}/zinit.zsh
  source ${0:h}/alias.zsh
  source ${0:h}/keymap.zsh

  source ~/.zi/evaled/zoxide.zsh
  source ~/.zi/evaled/wt.zsh
  source ~/.zi/evaled/starship.zsh
fi

