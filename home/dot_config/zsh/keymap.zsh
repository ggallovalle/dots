## [[ section widgets

function kbw_copy_pipe_widget() {
  emulate -L zsh

  [[ -z $BUFFER ]] && return
  [[ $BUFFER == *'| wl-copy' ]] && return

  BUFFER="${BUFFER%%[[:space:]]#} | wl-copy"
  CURSOR=${#BUFFER}
}

function kbw_kitty_tab_widget() {
  emulate -L zsh

  local direction=${1-}
  [[ -n ${KITTY_WINDOW_ID-} ]] || return
  command -v kitten >/dev/null || return

  case $direction in
    next)
      kitten @ action next_tab
      ;;
    previous)
      kitten @ action previous_tab
      ;;
  esac
}

function kbw_kitty_next_tab_widget() {
  kbw_kitty_tab_widget next
}

function kbw_kitty_previous_tab_widget() {
  kbw_kitty_tab_widget previous
}


## end section widgets ]]


ZVM_VI_EDITOR='nvim'
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_CLIPBOARD_COPY_CMD='wl-copy'
ZVM_CLIPBOARD_PASTE_CMD='wl-paste -n'

function zvm_after_init() {
  source ~/.zi/evaled/tv.zsh
}

function zvm_after_lazy_keybindings() {
  zvm_define_widget kbw_copy_pipe_widget
  zvm_define_widget kbw_kitty_next_tab_widget
  zvm_define_widget kbw_kitty_previous_tab_widget

  zvm_bindkey viins '^Xy' kbw_copy_pipe_widget
  zvm_bindkey vicmd 'gt' kbw_kitty_next_tab_widget
  zvm_bindkey vicmd 'gT' kbw_kitty_previous_tab_widget
}

# https://github.com/jeffreytse/zsh-vi-mode
# better and friendlier vim mode
zi ice --light-mode
zi load jeffreytse/zsh-vi-mode

