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
# By default behaves like the builtin `history` (prints all entries).
# With -i, opens an fzf picker:
#   * Enter -> load the selected command onto the prompt
#   * Del   -> delete selected entries from history (supports multi-select)

# Parse "  EVT[*]  CMD..." -> bare event number.
_zsh_history_evt() {
  local line=$1
  line=${line##[[:space:]]##}
  line=${line%%[[:space:]]*}
  print -r -- ${line%\*}
}

function history() {
  local -a clear interactive session help
  zparseopts -E -D c=clear i=interactive s=session h=help -help=help

  if [[ -n "$help" ]]; then
    print -P "%Busage:%b history [-c] [-i [-s]] [-h|--help]"
    print
    print -P "%BOptions:%b"
    print "  -c           clear history"
    print "  -i           interactive fzf picker (Enter = use, Del = delete)"
    print "  -s           with -i, restrict to the current session"
    print "  -h, --help   show this help"
    return 0
  fi

  if [[ -n "$clear" ]]; then
    : >| "$HISTFILE"
    fc -p "$HISTFILE"
    return
  fi

  if [[ -z "$interactive" ]]; then
    builtin fc -l 1
    return
  fi

  if (( ! ${+commands[fzf]} )); then
    print -Pu2 "%F{red}history: -i requires fzf%f"
    return 1
  fi

  local -a fc_opts=()
  [[ -n "$session" ]] && fc_opts=(-I)

  local out
  out=$(builtin fc -lr "${fc_opts[@]}" 1 | \
    fzf --no-sort --multi --expect=del --query="${LBUFFER:-}" \
        --header='enter: use   del: delete') || return

  local key=${out%%$'\n'*}
  local rest=${out#*$'\n'}
  [[ -z $rest || ( $rest == $out && -z $key ) ]] && return

  if [[ -z $key ]]; then
    # Enter: take first selection, push command onto prompt
    local first=${rest%%$'\n'*}
    print -z -- "$history[$(_zsh_history_evt "$first")]"
    return
  fi

  # del: collect everything to remove, then do one combined file rewrite
  local line evt cmd
  local -a patterns
  while IFS= read -r line; do
    [[ -z $line ]] && continue
    evt=$(_zsh_history_evt "$line")
    cmd=$history[$evt]
    [[ -z $cmd ]] && continue
    print -P "%F{244}Removing history entry:%f"
    print -r "  ${cmd}"
    patterns+=("${(b)cmd}")
  done <<< "$rest"

  if (( ${#patterns} )); then
    local HISTORY_IGNORE="(${(j:|:)patterns})"
    fc -W
    fc -R "$HISTFILE"
  fi
}


## Don't save commands that returned 127 (command not found)
# zshaddhistory fires before execution so $? is not the current command's status;
# use a precmd hook that checks the real exit status and removes the last entry.
_zsh_history_filter_127() {
  local last_status=$?
  (( last_status == 127 )) || return 0

  # $history[$HISTCMD] gives just the last command, with no leading tab and
  # no trailing newline — unlike `fc -ln -1` which returns a *range* and
  # would include multiple entries joined by newlines.
  local last_cmd=$history[$HISTCMD]
  [[ -z $last_cmd ]] && return

  local HISTORY_IGNORE="${(b)last_cmd}"
  fc -W
  fc -R "$HISTFILE"
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _zsh_history_filter_127
