#!/usr/bin/env bash

DIRS=(
    "$HOME/doc"
    "$HOME/repo"
    "$HOME/src"
    # "$HOME"
)

if [[ $# -eq 1 ]]; then
    selected=$1
else
    selected=$(fd . "${DIRS[@]}" --type=dir --max-depth=2 \
        | sed "s|^$HOME/||" \
        | fzf --margin=5%)
    [[ $selected ]] && selected="$HOME/$selected"
fi

[[ ! $selected ]] && exit 0

selected_name=$(basename "$selected" | sed "s/\./dot/g")
if ! tmux has-session -t "$selected_name"; then
    tmux new-session -ds "$selected_name" -c "$selected"
    tmux select-window -t "$selected_name:1"
fi

tmux switch-client -t "$selected_name"
