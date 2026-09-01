# xdg
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export EDITOR=nvim
export BROWSER=zen-browser
export MANPAGER='nvim +Man!'
export STARSHIP_CONFIG="${XDG_CONFIG_HOME}/zsh/starship.toml"
export DOTFILES="${HOME}/dots"
export GHQ_ROOT="${HOME}/ghq"

# jdk
export JAVA_HOME="/usr/lib/jvm/default"

# android sdk
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

typeset -U path
path+=(
  "${XDG_CONFIG_HOME}/zsh/bin"
  "${XDG_DATA_HOME}/nvim/mason/bin"
  "${HOME}/.local/bin"
  "${XDG_DATA_HOME}/mise/shims"
  "${ANDROID_HOME}/cmdline-tools/latest/bin"
  "${ANDROID_HOME}/platform-tools"
)

# qt 5 wayland integration
export QT_QPA_PLATFORMTHEME=gtk3

# so that `android emulator start <device>` works
export QT_QPA_PLATFORM=xcb
# export QT_QPA_PLATFORM=wayland

export EZA_STRICT=1

