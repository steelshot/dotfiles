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

## history — `-c` wipes current session and HISTFILE with confirmation.
##           `-i` opens an interactive fzf picker to recall a command.
function history() {
  if [[ $1 == -c ]]; then
    print -n "This will wipe all history. Continue? [y/N] " >/dev/tty
    local REPLY
    read -k 1 REPLY </dev/tty
    print >/dev/tty
    [[ $REPLY = [yY] ]] || return 0
    fc -p /dev/null
    : >| "${HISTFILE}"
    print -P "%F{green}History cleared.%f" >/dev/tty
    return
  fi

  if [[ $1 == -i ]]; then
    (( ${+functions[fzf-history-widget]} )) || { print -P -u2 "%F{red}history -i: fzf widget not loaded.%f"; return 1 }
    fzf-history-widget
    return
  fi

  builtin fc -l "${@:-1}"
}

## watch — prefers viddy when available, falls back to system watch.
function watch() {
  local backend
  local -a defaults
  if (( ${+commands[viddy]} )); then
    backend=${commands[viddy]}
    defaults=(-dtws --disable_auto_save)
  elif (( ${+commands[watch]} )); then
    backend=${commands[watch]}
    defaults=(-n1 -t -d)
  else
    print -P -u2 "%F{red}watch: neither viddy nor watch is installed.%f"
    return 1
  fi

  if (( $# == 0 )); then
    "$backend" -h
    return
  fi

  local -a flags=("${defaults[@]}")
  while (( $# )); do
    case $1 in
      -h|--help) "$backend" -h; return ;;
      -n|--interval)
        flags+=("$1")
        [[ -n $2 && $2 != -* ]] && { flags+=("$2"); shift }
        ;;
      -*) flags+=("$1") ;;
      *)  break ;;
    esac
    shift
  done

  if (( $# == 0 )); then
    print -P -u2 "%F{red}watch: no command specified%f"
    return 1
  fi

  local cmd=$1; shift
  if (( ${+functions[$cmd]} )); then
    print -P -u2 "%F{red}watch: functions are not supported.%f"
    return 1
  fi

  local -a cmd_words
  if (( ${+aliases[$cmd]} )); then
    cmd_words=(${(z)aliases[$cmd]})
  else
    cmd_words=($cmd)
  fi

  "$backend" "${flags[@]}" "${cmd_words[@]}" "$@"
}
