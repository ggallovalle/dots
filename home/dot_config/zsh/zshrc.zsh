0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"


zmodload zsh/param/private
zmodload zsh/zutil

export HISTFILE="${XDG_STATE_HOME}/zsh/history"
export HISTSIZE=10000
export SAVEHIST=10000
setopt INC_APPEND_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS HIST_REDUCE_BLANKS

eval "$(mise activate zsh)"


fpath+=( ${0:h}/functions ${0:h}/completions )
autoload -Uz ${0:h}/functions/*(.:t)

autoload -Uz compinit; compinit -u


source ${0:h}/zinit.zsh
source ${0:h}/alias.zsh

# j - jump [arg]
# ji - jump interactive
eval "$(zoxide init zsh --cmd j)"
eval "$(starship init zsh)"
