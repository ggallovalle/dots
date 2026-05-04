0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

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


# generated_completions_count=0

# # command → completion generator mapping
# typeset -A _completion_cmds

# _completion_cmds=(
#   # can't be move to zi snippet, has to be generated
#   # https://github.com/zellij-org/zellij/blob/a8372a09cd7ac14af0016b38fd9561f975ec17f3/Cargo.toml#L143
#   zellij   "zellij setup --generate-completion zsh"
#   # can't be move to zi snippet, has to be generated
#   uv       "uv generate-shell-completion zsh"
#   # can't be move to zi snippet, has to be generated
#   hl       "hl --shell-completions zsh _hl"
#   # can't be move to zi snippet, has to be generated
#   codex    "codex completion zsh"
#   # can't be move to zi snippet, has to be generated
#   glab "glab completion -s zsh"
# )

# for _complete_this _gen_cmd in ${(kv)_completion_cmds}; do
#   _target="${0:h}/completions/_${_complete_this}"

#   if (( ${+commands[${_complete_this}]} )) && [[ ! -e "$_target" ]]; then
#     echo "'${_complete_this}' generate completion"
#     eval "$_gen_cmd" > "$_target"
#     (( generated_completions_count++ ))
#   fi
# done

# if [[ $generated_completions_count -gt 0 ]]; then
#   echo "Generated ${generated_completions_count} completions"
# fi


# if [[ ! -f "${Plugins[KBROOM_DIR]}/mise.zsh" ]]; then
#     echo "Generated mise activate"
#     mise activate zsh >> "${Plugins[KBROOM_DIR]}/mise.zsh"
# fi

# source "${Plugins[KBROOM_DIR]}/mise.zsh"

# if [[ ! -f "${Plugins[KBROOM_DIR]}/typspec.zsh" ]]; then
#     typspec completion zsh > "${Plugins[KBROOM_DIR]}/typspec.zsh"
# fi

# source "${Plugins[KBROOM_DIR]}/typspec.zsh"
