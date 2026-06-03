## [[ section widgets

function kbw_copy_pipe_widget() {
  emulate -L zsh

  [[ -z $BUFFER ]] && return
  [[ $BUFFER == *'| wl-copy' ]] && return

  BUFFER="${BUFFER%%[[:space:]]#} | wl-copy"
  CURSOR=${#BUFFER}
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

  zvm_bindkey viins '^Xy' kbw_copy_pipe_widget
}

# https://github.com/jeffreytse/zsh-vi-mode
# better and friendlier vim mode
zi ice --light-mode
zi load jeffreytse/zsh-vi-mode

