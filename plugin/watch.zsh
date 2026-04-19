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

if (( ${+commands[viddy]} )); then
  _ZSH_WATCH=viddy
  _ZSH_WATCH_FLAGS=(-dtws --disable_auto_save)
else
  _ZSH_WATCH=watch
  _ZSH_WATCH_FLAGS=(-n1 -t -d)
fi

_zsh_watch_run() {
  if ! command -v "$_ZSH_WATCH" >/dev/null 2>&1; then
    print -P "%F{red}Command $_ZSH_WATCH not found.%f"
    return 1
  fi

  local -a watch_flags=()

  if (( $# == 0 )); then
    "$_ZSH_WATCH" -h
    return
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h | --help)
        "$_ZSH_WATCH" -h
        return
        ;;
      -n | --interval | -q | --equexit | -d | --differences)
        watch_flags+=("$1")
        if [[ ! $2 = -* ]]; then
          watch_flags+=("$2")
          shift
        fi
        ;;
      -*) watch_flags+=("$1") ;;
      *) break ;;
    esac
    shift
  done

  if (( ${#watch_flags[@]} == 0 )); then
    watch_flags+=("${_ZSH_WATCH_FLAGS[@]}")
  fi

  if (( $+functions[$1] )); then
    print -P "%F{red}Functions are not supported.%f"
    return 1
  fi

  local cmd="$1"
  local -a cmd_args=("${@:2}")

  # expand aliases
  unset 'functions[_zsh-watch-expand]'
  # shellcheck disable=SC2154
  functions[_zsh-watch-expand]=$cmd
  (( $+functions[_zsh-watch-expand] )) && cmd=${functions[_zsh-watch-expand]#$'\t'}

  "$_ZSH_WATCH" "${watch_flags[@]}" "$cmd" "${cmd_args[@]}"
}

watch() {
  _zsh_watch_run "$@"
}
