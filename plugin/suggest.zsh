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

## Suggest modern tool replacements when legacy commands are used.
# preexec output bypasses the command's own redirections; /dev/tty keeps it
# off captured output and silently no-ops when there's no tty (cron, CI).

# Pipe-separated candidates — first found in $PATH wins (handles fdfind/batcat).
typeset -gA ZSH_SUGGEST_MAP=(
  find  'fd|fdfind'
  grep  'rg'
  cat   'bat|batcat'
  diff  'delta'
  ls    'eza|exa'
  du    'dust'
  df    'duf'
  ps    'procs'
  top   'btop|btm'
  sed   'sd'
  cut   'choose'
)

_zsh_suggest_better() {
  # $2 is post-alias; aliasing find=fd means this never fires for that user.
  local first=${${(z)2}[1]}
  local candidates=${ZSH_SUGGEST_MAP[$first]}
  [[ -z $candidates ]] && return

  local better c
  for c in ${(s:|:)candidates}; do
    (( ${+commands[$c]} )) && { better=$c; break }
  done
  [[ -z $better ]] && return
  [[ -w /dev/tty ]] || return

  print -P "%F{244}hint:%f %B$first%b → consider %F{6}%B$better%b%f" >/dev/tty
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec _zsh_suggest_better
