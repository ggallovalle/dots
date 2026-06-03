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

HISTFILE="${XDG_STATE_HOME}/zsh/history"
HISTSIZE=100000
SAVEHIST=100000

# sizes
HISTSIZE=100000          # in-memory history
SAVEHIST=100000         # saved to HISTFILE
# append, don't overwrite
setopt APPEND_HISTORY
# share history between open shells
setopt SHARE_HISTORY
# write each command as soon as accepted
setopt INC_APPEND_HISTORY 
# better timestamps + duration in history file
setopt EXTENDED_HISTORY
# dedupe
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_FIND_NO_DUPS
# don't save commands starting with space
setopt HIST_IGNORE_SPACE
# don't save repeated command twice in row
setopt HIST_IGNORE_DUPS
# remove extra blanks before saving
setopt HIST_REDUCE_BLANKS

# https://github.com/zsh-users/zsh-autosuggestions
typeset -ga ZSH_AUTOSUGGEST_STRATEGY=(match_prev_cmd)
zi ice --wait --lucid --atload="!_zsh_autosuggest_start"
zi load zsh-users/zsh-autosuggestions

zi ice --wait --lucid --atinit="source ${0:h}/atinit/zsh-history-substring-search.zsh"
zi load zsh-users/zsh-history-substring-search

# replaced by tv-shell-history via tv init zsh
# zstyle ":history-search-multi-word" page-size "8"
# zstyle :plugin:history-search-multi-word reset-prompt-protect 1
# # `<C-r>` to search backwards
# zi ice --wait --lucid
# zi load z-shell/H-S-MW

## end section - better history navigation and search
#
# zi load z-shell/zui
# `<C-b>` or `zbrowse` to open it
# zi load z-shell/zbrowse

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
