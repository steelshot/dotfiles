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

# shellcheck disable=SC2154,SC2086,SC2296,SC2034,SC2043  # zsh-specific syntax: parameter flags, commands assoc array



(( ${#_ZSH_TOOL_COMPLETIONS} == 0 )) && return

(
  compdir="${0:h:h}/functions"
  mkdir -p "$compdir"

  # shellcheck disable=SC2043
  for tool in ${(@k)_ZSH_TOOL_COMPLETIONS}; do
    subcmd="${_ZSH_TOOL_COMPLETIONS[$tool]}"
    if command -v "$tool" >/dev/null 2>&1; then
      compfile="${compdir}/_${tool}"
      if [[ ! -e "$compfile" || "$compfile" -ot "${commands[$tool]}" ]]; then
        $tool ${(z)subcmd} >| "$compfile" \
          && print -P "%F{244}* Regenerated completions for %f%B${tool}%b%F{244}.%f"
      fi
    fi
  done
)

unset _ZSH_TOOL_COMPLETIONS
