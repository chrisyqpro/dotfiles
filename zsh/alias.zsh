alias \
  cp="cp -iv" \
  mv="mv -iv" \
  rm="rm -vI" \
  bc="bc -ql" \
  mkd="mkdir -pv" \

alias zcfg="$EDITOR $ZDOTDIR/.zshrc"
alias vim="nvim"
alias vi="nvim"
alias cgs="cargo +stable"
alias cgn="cargo +nightly"
alias cgl="CARGO_PROFILE_DEV_CODEGEN_BACKEND=cranelift cargo +nightly -Zcodegen-backend"
alias gorom="~/game/retro/gorom/bin/gorom"

alias ls="gls -F --color=auto --group-directories-first"
alias ll="ls -lh"
alias la="ll -a"
alias tree="tree -L 2"
alias as-tree="\\tree --fromfile"
