#!/usr/bin/env zsh

#
# Copyright (c) 2026 Džiugas Eiva
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

emulate -L zsh
setopt extended_glob no_nomatch pipefail
zmodload zsh/datetime

REPO=${DOTFILES_REPO:-steelshot/dotfiles}
BRANCH=${DOTFILES_BRANCH:-main}
TARBALL="https://codeload.github.com/${REPO}/tar.gz/refs/heads/${BRANCH}"

confirm() {
  local reply
  print -nP "$1" >/dev/tty
  read -k 1 reply < /dev/tty
  print >/dev/tty
  [[ $reply = [yY] ]]
}

confirm "%F{red}%BThis will remove all your zsh dotfiles and purge zim caches.%b%f Continue? [y/N] " \
  || { print -P "%F{244}Aborted.%f" >/dev/tty; exit 1 }

# Inform about missing recommended CLI tools
() {
  local tool
  print -P "%F{244}Checking recommended tools:%f"
  for tool in eza zoxide fzf direnv bat fd rg delta btop dust duf procs kubectl helm gh yq nano; do
    if (( ${+commands[$tool]} )); then
      print -P "  %F{green}✔%f %B${tool}%b %F{244}${commands[$tool]}%f"
    else
      print -P "  %F{red}✘%f %B${tool}%b"
    fi
  done
} >/dev/tty

confirm "%F{red}%BARE YOU REALLY SURE?%b%f [y/N] " \
  || { print -P "%F{244}Aborted.%f" >/dev/tty; exit 1 }

if (( ${+commands[curl]} )); then
  fetch() { curl -fsSL "$1"; }
elif (( ${+commands[wget]} )); then
  fetch() { wget -qO- "$1"; }
else
  print -P "%F{red}install: curl or wget is required.%f" >/dev/tty; exit 1
fi
(( ${+commands[tar]} )) || { print -P "%F{red}install: tar is required.%f" >/dev/tty; exit 1 }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

print -P "%F{244}Downloading ${REPO}#${BRANCH}...%f" >/dev/tty
fetch "$TARBALL" | tar -xz -C "$tmp" --strip-components=1 || {
  print -P "%F{red}install: download/extract failed.%f" >/dev/tty; exit 1
}

src="$tmp/dotfiles"
[[ -d $src ]] || { print -P "%F{red}install: ${src} missing in archive.%f" >/dev/tty; exit 1 }

print -P "%F{244}Purging zim/zsh caches...%f" >/dev/tty
zdotdir=${ZDOTDIR:-$HOME}
cache=${XDG_CACHE_HOME:-$HOME/.cache}
targets=(
  "${ZIM_HOME:-$zdotdir/.zim}"(N)
  "$cache"/p10k-*(N)
  "$cache/gitstatus"(N)
  "$cache"/dotfiles-hook-*.zsh(N)
  "$cache"/dotfiles-hook-*.zsh.zwc(N)
  "$zdotdir"/.zcompdump*(N)
  "$zdotdir"/*.zwc(N)
)
[[ "$zdotdir" != "$HOME" ]] && targets+=("$HOME"/*.zwc(N))
for t in $targets; do
  [[ -n $t && $t != / ]] && rm -rf "$t"
done

print -P "%F{244}Installing fresh dotfiles...%f" >/dev/tty
local zshenv="$HOME/.zshenv"
if [[ -f $zshenv ]]; then
  local backup="${zshenv}.bak.$(strftime '%Y%m%d%H%M%S' $EPOCHSECONDS)"
  cp "$zshenv" "$backup"
  print -P "%F{244}Backed up .zshenv → ${backup:t}%f" >/dev/tty
fi
local f rel dest failed=0
for f in "$src"/**/*(D.); do
  rel=${f#$src/}
  dest="$HOME/$rel"
  if ! mkdir -p "${dest:h}" || ! cp -f "$f" "$dest"; then
    print -P "%F{red}install: failed to install ${rel}%f" >/dev/tty
    failed=1
  fi
done
(( failed )) && { print -P "%F{red}install: some files failed to install.%f" >/dev/tty; exit 1 }

print -P "%F{green}Done.%f %F{244}Reloading shell...%f" >/dev/tty
# Reattach stdin to the tty; under `curl | zsh` stdin is the consumed pipe.
exec zsh < /dev/tty
