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

(( ${#_ZSH_TOOL_COMPLETIONS} == 0 )) && return

_zsh_setup_completions() {
  local compdir="${0:h:h}/functions"
  local tool subcmd compfile generated=0

  # fpath needs the dir even before it exists; compinit handles missing dirs.
  [[ -z ${fpath[(r)$compdir]} ]] && fpath=("$compdir" $fpath)

  for tool in ${(@k)_ZSH_TOOL_COMPLETIONS}; do
    (( ${+commands[$tool]} )) || continue
    subcmd="${_ZSH_TOOL_COMPLETIONS[$tool]}"
    compfile="${compdir}/_${tool}"
    [[ -e $compfile && $compfile -nt ${commands[$tool]} ]] && continue

    [[ -d $compdir ]] || mkdir -p "$compdir" || return 1
    if ${commands[$tool]} ${(z)subcmd} >| "$compfile"; then
      print -P "%F{244}* Regenerated completions for %f%B${tool}%b%F{244}.%f"
      generated=1
    fi
  done

  (( generated )) && (( $+functions[compinit] )) && \
    compinit -u -d "${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
}

_zsh_setup_completions
unset -f _zsh_setup_completions
unset _ZSH_TOOL_COMPLETIONS
