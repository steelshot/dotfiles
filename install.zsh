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

REPO=${DOTFILES_REPO:-steelshot/dotfiles}
BRANCH=${DOTFILES_BRANCH:-main}
TARBALL="https://codeload.github.com/${REPO}/tar.gz/refs/heads/${BRANCH}"

confirm() {
  local reply
  print -nP "$1"
  read -k 1 reply < /dev/tty
  print
  [[ $reply = [yY] ]]
}

confirm "%F{red}%BThis will remove all your zsh dotfiles and purge zim caches.%b%f Continue? [y/N] " \
  || { print -P "%F{244}Aborted.%f"; exit 1 }
confirm "%F{red}%BARE YOU REALLY SURE?%b%f [y/N] " \
  || { print -P "%F{244}Aborted.%f"; exit 1 }

if (( ${+commands[curl]} )); then
  fetch() { curl -fsSL "$1"; }
elif (( ${+commands[wget]} )); then
  fetch() { wget -qO- "$1"; }
else
  print -Pu2 "%F{red}install: curl or wget is required.%f"; exit 1
fi
(( ${+commands[tar]} )) || { print -Pu2 "%F{red}install: tar is required.%f"; exit 1 }

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

print -P "%F{244}Downloading ${REPO}#${BRANCH}...%f"
fetch "$TARBALL" | tar -xz -C "$tmp" --strip-components=1 || {
  print -Pu2 "%F{red}install: download/extract failed.%f"; exit 1
}

src="$tmp/dotfiles"
[[ -d $src ]] || { print -Pu2 "%F{red}install: ${src} missing in archive.%f"; exit 1 }

dotfiles=("$src"/.*(.N))
(( ${#dotfiles} )) || { print -Pu2 "%F{red}install: no dotfiles in ${src}.%f"; exit 1 }

print -P "%F{244}Purging zim/zsh caches...%f"
zdotdir=${ZDOTDIR:-$HOME}
cache=${XDG_CACHE_HOME:-$HOME/.cache}
targets=(
  "${ZIM_HOME:-$zdotdir/.zim}"(N)
  "$cache"/p10k-*(N)
  "$cache/gitstatus"(N)
  "$zdotdir"/.zcompdump*(N)
  "$zdotdir"/*.zwc(N)
)
[[ "$zdotdir" != "$HOME" ]] && targets+=("$HOME"/*.zwc(N))
for t in $targets; do
  [[ -n $t && $t != / ]] && rm -rf "$t"
done

print -P "%F{244}Installing fresh dotfiles...%f"
for f in "${dotfiles[@]}"; do
  cp -f "$f" "$HOME/${f:t}"
done

print -P "%F{green}Done.%f %F{244}Reloading shell...%f"
# Reattach stdin to the tty; under `curl | zsh` stdin is the consumed pipe.
exec zsh < /dev/tty
