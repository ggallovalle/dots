0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

if [[ ! -f $HOME/.zi/bin/zi.zsh ]]; then
  print -P "%F{33}▓▒░ %F{160}Installing (%F{33}z-shell/zi%F{160})…%f"
  command mkdir -p "$HOME/.zi" && command chmod go-rwX "$HOME/.zi"
  command git clone -q --depth=1 --branch "main" https://github.com/z-shell/zi "$HOME/.zi/bin" && \
    print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
    print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi
source "$HOME/.zi/bin/zi.zsh"
autoload -Uz _zi
(( ${+_comps} )) && _comps[zi]=_zi

# examples here -> https://wiki.zshell.dev/ecosystem/category/-annexes
zicompinit # <- https://wiki.zshell.dev/docs/guides/commands
zi light-mode for \
  z-shell/z-a-meta-plugins \
  @annexes @zunit


zi ice --lucid --wait --as=completion --blockf --has=fd
zi snippet https://github.com/sharkdp/fd/blob/master/contrib/completion/_fd

zi ice --lucid --wait --as=completion --blockf --has=docker
zi snippet https://github.com/docker/cli/blob/master/contrib/completion/zsh/_docker

zi ice --lucid --wait --as=completion --blockf --has=bun --mv="bun.zsh -> _bun"
zi snippet https://github.com/oven-sh/bun/blob/main/completions/bun.zsh

zi ice --lucid --wait --as=completion --blockf --has=just --mv="just.zsh -> _just"
zi snippet https://github.com/casey/just/blob/master/completions/just.zsh

zi ice --lucid --wait --as=completion --blockf --has=mise
zi snippet https://github.com/jdx/mise/blob/main/completions/_mise

zi ice --lucid --wait --as=completion --blockf --has=opencode
zi snippet https://github.com/PEMessage/opencode-zsh-completion/blob/main/_opencode


# https://github.com/jeffreytse/zsh-vi-mode
# better and friendlier vim mode
# 2025-04-21
function zvm_config() {
  ZVM_VI_EDITOR='nvim'
}
zi ice --light-mode --ver="f82c4c8"
zi load jeffreytse/zsh-vi-mode

# https://github.com/z-shell/F-Sy-H
# syntax highlighting for zsh terminal with support for themes
# commands:
# fast-theme $NAME # switch theme
# fast-theme -l # list themes
# fast-theme -t $NAME # show theme preview
zi ice --light-mode --lucid --wait --atinit="ZI[COMPINIT_OPTS]=-C; zicompinit; zicdreplay"
zi load z-shell/F-Sy-H


## section - better history navigation and search
## try to get a fish-like history search experience

# conflicts with zsh_autosuggest_strategy=(match_prev_cmd)
# setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
# setopt hist_ignore_all_dups   # remove older duplicate entries from the history
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_reduce_blanks     # remove superfluous blanks from history items
setopt hist_save_no_dups      # do not write a duplicate event to the history file
setopt inc_append_history     # allow multiple terminal sessions to append to one history
setopt inc_append_history     # write to the history file immediately, not when the shell exits.
setopt share_history          # share command history data
export HISTFILE="${XDG_STATE_HOME}/zsh/history"

# https://github.com/zsh-users/zsh-autosuggestions
typeset -ga ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd)
zi ice --wait --lucid --atload="!_zsh_autosuggest_start"
zi load zsh-users/zsh-autosuggestions

zi ice --wait --lucid --atinit="source ${0:h}/atinit/zsh-history-substring-search.zsh"
zi load zsh-users/zsh-history-substring-search

zstyle ":history-search-multi-word" page-size "8"
zstyle :plugin:history-search-multi-word reset-prompt-protect 1
# `<C-r>` to search backwards
zi ice --wait --lucid
zi load z-shell/H-S-MW

## end section - better history navigation and search

zi load z-shell/zui
# `<C-b>` or `zbrowse` to open it
zi load z-shell/zbrowse

# # ignore expansion of these regular/global aliases
# export ZPWR_EXPAND_BLACKLIST=()
# # aliases expand in first position
# export ZPWR_EXPAND=true
# # aliases expand in second position after sudo
# export ZPWR_EXPAND_SECOND_POSITION=true
# # expand globs, history etc with zle expand-word
# export ZPWR_EXPAND_NATIVE=true
# # spelling correction in zsh-expand plugin
# export ZPWR_CORRECT=true
# # aliases expand after spelling correction
# export ZPWR_CORRECT_EXPAND=true
# # expand inside "
# export ZPWR_EXPAND_QUOTE_DOUBLE=true
# # expand inside '
# export ZPWR_EXPAND_QUOTE_SINGLE=false
# # expand into history any unexpanded
# export ZPWR_EXPAND_TO_HISTORY=false
# zi ice --lucid --nocompile
# zinit load MenkeTechnologies/zsh-expand
