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


## Don't save commands that returned 127 (command not found).
# Uses precmd rather than zshaddhistory because $? at zshaddhistory time
# reflects the previous command, not the one just entered.
_zsh_history_filter_127() {
  local last_status=$?
  (( last_status == 127 )) || return 0

  # $history[$HISTCMD] is the exact last command; fc -ln -1 can return multiple entries.
  local last_cmd=$history[$HISTCMD]
  [[ -z $last_cmd ]] && return

  local HISTORY_IGNORE="${(b)last_cmd}"
  fc -W
  fc -R "$HISTFILE"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_history_filter_127
