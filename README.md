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
