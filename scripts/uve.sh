#!/usr/bin/env bash
# uve ─ Edit a Python script in Neovim with the right uv-managed venv.
# Usage: uve path/to/script.py [extra nvim args…]

set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "usage: uve <script.py> [nvim-args…]" >&2
  exit 1
fi

script=$1
shift # forward any extra args to nvim
script_abs=$(realpath "$script")
script_dir=$(dirname "$script_abs")

if [[ ! -f "$script_abs" ]]; then
  echo "nvpy: '$script' is not a file" >&2
  exit 1
fi

activate_and_echo() {
  local activate=$1
  # shellcheck disable=SC1090
  source "$activate"
  echo "venv activated at $activate"
}

# Check for a project venv (.venv)
project_python=$(
  cd "$script_dir" && uv python find 2>/dev/null || true
)

if [[ -n "$project_python" && "$project_python" == */.venv/* ]]; then
  activate_and_echo "$(dirname "$project_python")/activate"
  exec nvim "$script_abs" "$@"
fi

# Check for a PEP 723 script venv
script_python=$(uv python find --script "$script_abs" 2>/dev/null || true)

if [[ -n "$script_python" && "$script_python" == *".cache/uv/environments"* ]]; then
  activate_and_echo "$(dirname "$script_python")/activate"
  exec nvim "$script_abs" "$@"
fi

echo "use uv first (no environment found for $script_abs)" >&2
exit 1
