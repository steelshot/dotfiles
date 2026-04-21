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

typeset -g _DOTFILES_MODULE_ROOT="${0:A:h}"

## Dotfile drift check
[[ -z "$skip_dotfile_compare" ]] && () {
  local src="$1/dotfiles" sh rel home
  for sh in "$src"/**/*(D.); do
    rel=${sh#$src/}
    [[ $rel == .zshenv ]] && continue
    home="$HOME/$rel"
    if [[ ! -e "$home" ]]; then
      print -P "$rel %F{red}is missing%f" >/dev/tty
    elif ! command cmp -s "$sh" "$home"; then
      if [[ "$sh" -nt "$home" ]]; then
        print -P "$rel %F{red}is outdated%f" >/dev/tty
      else
        print -P "$rel %F{yellow}differs%f" >/dev/tty
      fi
    fi
  done
} "${_DOTFILES_MODULE_ROOT}"

source "${_DOTFILES_MODULE_ROOT}/configuration.zsh"
for sh in "${_DOTFILES_MODULE_ROOT}"/plugin/*.zsh; do source "$sh"; done
