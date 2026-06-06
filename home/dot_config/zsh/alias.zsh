ABBR_SET_EXPANSION_CURSOR=1
alias src='clear; exec zsh'
alias resrc='source ~/.zshrc'
alias ..='cd ..'
alias ...='cd ../..'
alias rmr='rm -r'
alias rmrf='rm -rf'
alias cpr='cp -ri'
alias xhome='cd ~'
alias xconfig='cd $XDG_CONFIG_HOME'
alias xdata='cd $XDG_DATA_HOME'
alias xcode='cd $HOME/ghq/github.com/ggallovalle'
alias xdots='cd $DOTFILES'
alias xgh='cd $HOME/ghq/github.com'

if (( ${+commands[eza]} )); then
  export EZA_STRICT=1
  alias l='eza --group-directories-first --git-ignore'
  alias la='eza -A --group-directories-first --git-ignore'
  alias laa='eza -A --group-directories-first'
  alias ll='eza -lh --no-user --time-style=iso --group-directories-first --git --git-repos --git-ignore'
  alias lla='eza -lhA --no-user --time-style=iso --group-directories-first --git --git-repos --git-ignore'
  alias llaa='eza -lhA --no-user --time-style=iso --group-directories-first --git --git-repos'
  alias ld='eza -d --git'
  alias lt='eza --git-ignore --group-directories-first -T'
  alias lt2='eza --git-ignore --group-directories-first -TL 2'
  alias lt3='eza --git-ignore --group-directories-first -TL 3'
  alias lt4='eza --git-ignore --group-directories-first -TL 4'
  alias lta='eza --git-ignore -ATL 3'
  alias ltaa='eza -ATL 3'
fi

if (( ${+commands[chezmoi]} )); then
  abbr add -q cac='chezmoi apply ~/.config/%'
  abbr add -q cah='chezmoi apply ~/%'
  abbr add -q ca='chezmoi apply'
fi
