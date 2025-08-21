# Dotfiles

My configuration files inspired by some other repos.

- Use shell scripts to link config files and install programs.
- Try keeping shell script as strictly compatible with POSIX standard as possible.
  (Use shellcheck to check.)
- Inspired by these configs:
  - [andrew8088](https://github.com/andrew8088/dotfiles)
  - [Sylvan Franklin](https://github.com/SylvanFranklin)

## Install

```sh
./install/bootstrap.sh
```

## Local ZSH Config

The bootstrap.sh will setup a .env.sh file at $HOME to export the actual path to
this repo. The content may vary per machine so it's not committed, hence it can
be used to define any local setting for the machine as well.
