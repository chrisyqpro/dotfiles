export EDITOR="nvim"
export COLORTERM="truecolor"
export MANPAGER='nvim +Man!'
export MANWIDTH=80
HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=1000000000
SAVEHIST=1000000000

# Tell SSH to use gpg agent
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null
