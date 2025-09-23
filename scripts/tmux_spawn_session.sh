#!/usr/bin/env bash
set -euo pipefail

FD_BIN=${FD_BIN:-fd}

if ! command -v "$FD_BIN" >/dev/null 2>&1; then
  if command -v fdfind >/dev/null 2>&1; then
    FD_BIN=fdfind
  else
    echo "Error: fd/fdfind not found in PATH (PATH=$PATH)" >&2
    exit 1
  fi
fi

DIRS=(
  "$HOME/doc"
  "$HOME/src/repo"
  "$HOME/src"
)

if [[ $# -eq 1 ]]; then
  selected=$1
else
  selected=$($FD_BIN . "${DIRS[@]}" --type=directory --max-depth=1 \
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
