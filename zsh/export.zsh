export EDITOR="nvim"
export TERMINAL="alacritty"
export MANPAGER='nvim +Man!'
export MANWIDTH=80
HISTSIZE=50000
SAVEHIST=100000

# Tell SSH to use gpg agent
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
gpg-connect-agent updatestartuptty /bye > /dev/null
