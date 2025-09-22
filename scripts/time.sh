#!/usr/bin/env bash

CATEGORIES=(
  "CONFIG"
  "JOBHUNT"
  "PROJECT"
  "CODEJAM"
  "LANGUAGE"
  "GAMING"
  "MEAL"
  "WORKOUT"
  "VIDEO"
  "PROGRAMMING"
  "WASTED"
  "STOP"
)

selected=$(printf "%s\n" "${CATEGORIES[@]}" | fzf --margin=5%)

[[ ! $selected ]] && exit 0

if [[ "$selected" == "STOP" ]]; then
  timew stop
  tmux set -g status-right ""
else
  timew start "$selected"
  tmux set -g status-right "$selected "
fi
