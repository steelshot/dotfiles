# dotfiles

Just personal dotfiles with some zsh plugins/aliases.

## Install

One-shot bootstrap (downloads the repo tarball, purges zim/zsh caches, drops the fresh dotfiles into `$HOME`):

```sh
curl -fsSL https://raw.githubusercontent.com/steelshot/dotfiles/main/install.zsh | zsh
```

or with `wget`:

```sh
wget -qO- https://raw.githubusercontent.com/steelshot/dotfiles/main/install.zsh | zsh
```

You'll be asked to confirm twice. When it finishes it will reload your shell with the new configuration.

### Non-interactive install

Set these environment variables to run without prompts (e.g. from automation):

- `DOTFILES_UNATTENDED=1` — auto-confirm both prompts and skip the final shell reload.
- `DOTFILES_QUIET=1` — silence all status output (also removes the `/dev/tty` dependency, so it works with no controlling terminal).

```sh
DOTFILES_UNATTENDED=1 DOTFILES_QUIET=1 curl -fsSL https://raw.githubusercontent.com/steelshot/dotfiles/main/install.zsh | zsh
```

or with `wget`:

```sh
DOTFILES_UNATTENDED=1 DOTFILES_QUIET=1 wget -qO- https://raw.githubusercontent.com/steelshot/dotfiles/main/install.zsh | zsh
```
