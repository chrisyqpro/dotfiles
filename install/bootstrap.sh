#!/usr/bin/env bash
#
# bootstrap the configuration process.
#
# SPDX-License-Identifier: GPL-3.0-or-later
# TODO: Expand to a more powerful tooll that can also handle installation and
#       auto path parsing.
# TODO: Add pre-steps like install zsh plugin manager or homebrew.

cd "$(dirname "$0")/.."
DOTFILES=$(pwd -P)

set -e # exit on error

echo ''

# message printers
info() {
  printf "\r  [ \033[00;34m..\033[0m ] %s\n" "$1"
}

user() {
  printf "\r  [ \033[0;33m??\033[0m ] %s\n" "$1"
}

success() {
  printf "\r\033[2K  [ \033[00;32mOK\033[0m ] %s\n" "$1"
}

fail() {
  printf "\r\033[2K  [\033[0;31mFAIL\033[0m] %s\n" "$1"
  echo ''
  exit
}

link_file() {
  local src=$1 dst=$2

  local overwrite=
  local backup=
  local skip=
  local action=

  if [[ -f "$dst" ]] || [[ -d "$dst" ]] || [[ -L "$dst" ]]; then

    if [[ "$overwrite_all" == "false" ]] \
      && [[ "$backup_all" == "false" ]] && [[ "$skip_all" == "false" ]]; then

      # ignoring exit 1 from readlink in case where file already exists
      # shellcheck disable=SC2155
      local currentSrc="$(readlink "$dst")"

      if [[ "$currentSrc" == "$src" ]]; then

        skip=true

      else

        user "File already exists: $dst ($(basename "$src")), what do you want to do?\n\
        [s]kip, [S]kip all, [o]verwrite, [O]verwrite all, [b]ackup, [B]ackup all?"
        read -r -n 1 action </dev/tty

        case "$action" in
          o)
            overwrite=true
            ;;
          O)
            overwrite_all=true
            ;;
          b)
            backup=true
            ;;
          B)
            backup_all=true
            ;;
          s)
            skip=true
            ;;
          S)
            skip_all=true
            ;;
          *) ;;
        esac

      fi

    fi

    overwrite=${overwrite:-$overwrite_all}
    backup=${backup:-$backup_all}
    skip=${skip:-$skip_all}

    if [[ "$overwrite" == "true" ]]; then
      rm -rf "$dst"
      success "removed $dst"
    fi

    if [[ "$backup" == "true" ]]; then
      mv "$dst" "${dst}.backup"
      success "moved $dst to ${dst}.backup"
    fi

    if [[ "$skip" == "true" ]]; then
      success "skipped $src"
    fi
  fi

  if [[ "$skip" != "true" ]]; then # "false" or empty
    ln -s "$1" "$2"
    success "linked $1 to $2"
  fi
}

install_dotfiles() {
  info 'installing dotfiles'

  local overwrite_all=false backup_all=false skip_all=false
  local linkfile

  find -H "$DOTFILES" -maxdepth 2 -name 'links.prop' -not -path '*.git*' \
    | while read -r linkfile; do
      local src dst dir
      while IFS='=' read -r src dst <&3; do
        src="${src//\$DOTFILES/$DOTFILES}"
        dst="${dst//\$HOME/$HOME}"
        dir=$(dirname "$dst")

        mkdir -p "$dir"
        link_file "$src" "$dst"
      done 3<"$linkfile"
    done
}

create_env_file() {
  if test -f "$HOME/.env.sh"; then
    success "$HOME/.env.sh file already exists, skipping"
  else
    echo "export DOTFILES=$DOTFILES" >"$HOME"/.env.sh
    success 'created ~/.env.sh'
  fi
}

install_dotfiles
create_env_file

echo ''
echo ''
success 'All installed!'
