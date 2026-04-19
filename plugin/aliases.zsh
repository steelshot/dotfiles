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

# fd aliases (https://github.com/sharkdp/fd)
(( ${+commands[fdfind]} )) && alias fd=fdfind
(( ${+commands[fd]} || ${+commands[fdfind]} )) && alias find='fd --color always'

# bat aliases (https://github.com/sharkdp/bat)
(( ${+commands[batcat]} )) && alias bat=batcat
(( ${+commands[bat]} || ${+commands[batcat]} )) && alias cat='bat -pP'

# ripgrep aliases (https://github.com/BurntSushi/ripgrep)
# --color=always: preserve grep-compatible output with colours
(( ${+commands[rg]} )) && alias grep='rg --color=always'

# delta aliases (https://github.com/dandavison/delta)
# --color-only: identical unified diff output, only adds colours
(( ${+commands[delta]} )) && alias diff='delta --color-only'

# ip aliases (built-in color support)
(( ${+commands[ip]} )) && alias ip='ip -color'

# man with tldr fallback (https://github.com/dbrgn/tealdeer)
# tries tldr first for quick examples, falls back to real man if page not found
if (( ${+commands[tldr]} )); then
  man() { tldr "$@" 2>/dev/null || command man "$@"; }
fi
