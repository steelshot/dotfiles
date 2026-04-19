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

## History wrapper
# `-i` opens atuin's TUI. `-c` wipes all history with confirmation
function history() {
  if [[ $1 == -i ]]; then
    (( ${+commands[atuin]} )) || { print -Pu2 "%F{red}history: -i requires atuin%f"; return 1 }
    atuin search -i
    return
  fi

  if [[ $1 == -c ]]; then
    print -n "This will wipe all history. Continue? [y/N] "
    local REPLY
    read -k 1
    print
    [[ $REPLY = [yY] ]] || return 0
    (( ${+commands[atuin]} )) && command rm -f "${XDG_DATA_HOME:-$HOME/.local/share}/atuin/history.db"*
    fc -p /dev/null
    print -P "%F{green}History cleared.%f"
    return
  fi

  (( ${+commands[atuin]} )) && _dotfiles_history_reload
  builtin fc -l "${@:-1}"
}

## Seed $history from atuin
# Self-removing precmd hook seeds on first prompt (masked by p10k instant-prompt);
# `history` re-calls in-process for fresh reads.
_dotfiles_history_reload() {
  local tmp
  tmp=$(mktemp) || return
  atuin history list --cmd-only --reverse 2>/dev/null > "$tmp"
  fc -R "$tmp"
  rm -f "$tmp"
}

if (( ${+commands[atuin]} )); then
  _dotfiles_history_load_once() {
    add-zsh-hook -d precmd _dotfiles_history_load_once
    _dotfiles_history_reload
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook precmd _dotfiles_history_load_once
fi
