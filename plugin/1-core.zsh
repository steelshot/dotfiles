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

# User-customisable maps — pre-declare in ~/.zshenv to add/override defaults.
typeset -gA DOTFILES_ALIASES     # alias → command
typeset -gA DOTFILES_SUGGEST     # legacy command → pipe-separated modern candidates
typeset -gA DOTFILES_COMPLETIONS # binary → completion subcommand

# ─── Defaults ────────────────────────────────────────────────────────────────

: ${DOTFILES_ALIASES[nano]:="nano --modernbindings"}
: ${DOTFILES_ALIASES[k]:="kubectl"}
: ${DOTFILES_ALIASES[cat]:="bat -Pp"}
: ${DOTFILES_ALIASES[top]:="btop"}
: ${DOTFILES_ALIASES[du]:="dust"}
: ${DOTFILES_ALIASES[df]:="duf"}
: ${DOTFILES_ALIASES[get]:="wget -cNq --show-progress"}
: ${DOTFILES_ALIASES[ls]:="eza --group-directories-first"}
: ${DOTFILES_ALIASES[ll]:="ls -l --git"}
: ${DOTFILES_ALIASES[l]:="ll -a"}
: ${DOTFILES_ALIASES[lah]:="ll -ah"}

: ${DOTFILES_SUGGEST[man]:="tldr"}
: ${DOTFILES_SUGGEST[find]:="fd|fdfind"}
: ${DOTFILES_SUGGEST[diff]:="delta"}
: ${DOTFILES_SUGGEST[ps]:="procs"}
: ${DOTFILES_SUGGEST[sed]:="sd"}
: ${DOTFILES_SUGGEST[cut]:="choose"}
: ${DOTFILES_SUGGEST[cd]:="z|zoxide"}

: ${DOTFILES_COMPLETIONS[yq]:="shell-completion zsh"}
: ${DOTFILES_COMPLETIONS[gh]:="completion -s zsh"}
: ${DOTFILES_COMPLETIONS[helm]:="completion zsh"}
: ${DOTFILES_COMPLETIONS[kubectl]:="completion zsh"}

# ─── Editor ──────────────────────────────────────────────────────────────────

(( ${+commands[nano]} )) && export EDITOR=nano VISUAL=nano

# ─── Pager ───────────────────────────────────────────────────────────────────

if (( ! ${+PAGER} )); then
  (( ${+commands[less]} )) && export PAGER=less || export PAGER=more
fi
export LESS=${LESS:---ignore-case --jump-target=4 --LONG-PROMPT --no-init --quit-if-one-screen --RAW-CONTROL-CHARS}

# ─── Colours ─────────────────────────────────────────────────────────────────

if [[ -z $NO_COLOR ]]; then
  export GREP_COLOR='37;45'
  export GREP_COLORS="mt=${GREP_COLOR}"
  (( ${+commands[grep]} )) && alias grep='grep --color=auto'

  # Coloured man pages via less
  export LESS_TERMCAP_mb=$'\E[1;31m'
  export LESS_TERMCAP_md=$'\E[1;31m'
  export LESS_TERMCAP_me=$'\E[0m'
  export LESS_TERMCAP_ue=$'\E[0m'
  export LESS_TERMCAP_us=$'\E[1;32m'
fi

## eza
(( ${+commands[eza]} )) && export EZA_COLORS='da=1;34:gm=1;34:Su=1;34'

# ─── Aliases ─────────────────────────────────────────────────────────────────

## Safety nets
if [[ $OSTYPE == linux* ]]; then
  alias chmod='chmod --preserve-root -v'
  alias chown='chown --preserve-root -v'
fi
(( ${+commands[safe-rm]} && ! ${+commands[safe-rmdir]} )) && alias rm=safe-rm

## Download — curl fallback if wget not installed
(( ! ${+commands[wget]} )) && : ${DOTFILES_ALIASES[get]:="curl -C - -LOR#"}

## User-defined (DOTFILES_ALIASES)
# Resolves alias chains through the map to find the ultimate binary before setting.
() {
  local name cmd
  _dotfiles_alias_ok() {
    local w=$1
    local -a seen
    while [[ -n ${DOTFILES_ALIASES[$w]} ]]; do
      (( ${seen[(i)$w]} <= ${#seen} )) && return 1  # cycle guard
      seen+=($w)
      w=${DOTFILES_ALIASES[$w]%% *}
    done
    (( ${+commands[$w]} ))
  }
  for name in ${(k)DOTFILES_ALIASES}; do
    cmd=${DOTFILES_ALIASES[$name]}
    _dotfiles_alias_ok ${cmd%% *} && alias $name="$cmd"
  done
  unset -f _dotfiles_alias_ok
}
unset DOTFILES_ALIASES

# ─── Suggestions ─────────────────────────────────────────────────────────────

() {
  typeset -gA _dotfiles_map=("${(@kv)DOTFILES_SUGGEST}")
  unset DOTFILES_SUGGEST

  # Reverse alias map is built on first prompt so all modules have loaded their aliases.
  typeset -gA _dotfiles_raliases
  _dotfiles_build_raliases() {
    add-zsh-hook -d precmd _dotfiles_build_raliases
    local a exp
    for a in ${(k)aliases}; do
      exp=${aliases[$a]}
      [[ ${#a} -ge ${#exp} ]] && continue
      [[ -z ${_dotfiles_raliases[$exp]} ]] || (( ${#a} < ${#_dotfiles_raliases[$exp]} )) || continue
      _dotfiles_raliases[$exp]=$a
    done
  }
  add-zsh-hook precmd _dotfiles_build_raliases

  _dotfiles_suggest_better() {
    local typed=$1 expanded=$2
    [[ -w /dev/tty ]] || return

    local first=${${(z)expanded}[1]}
    local candidates=${_dotfiles_map[$first]}
    if [[ -n $candidates ]]; then
      local better c
      for c in ${(s:|:)candidates}; do
        # includes ${+functions} to handle shell-function replacements e.g. z (zoxide)
        (( ${+commands[$c]} || ${+functions[$c]} )) && { better=$c; break }
      done
      [[ -n $better ]] && print -P "%F{244}hint:%f %B$first%b → consider %F{6}%B$better%b%f" >/dev/tty
    fi

    local exp_candidate shorter
    for exp_candidate in ${(k)_dotfiles_raliases}; do
      [[ $expanded != $exp_candidate && $expanded != "$exp_candidate "* ]] && continue
      shorter=${_dotfiles_raliases[$exp_candidate]}
      [[ ${${(z)typed}[1]} == $shorter ]] && continue
      print -P "%F{244}hint:%f %B${(q)exp_candidate}%b → consider alias %F{6}%B$shorter%b%f" >/dev/tty
      break
    done
  }
}
add-zsh-hook preexec _dotfiles_suggest_better

# ─── Completions ─────────────────────────────────────────────────────────────

() {
  # zim registers this directory in fpath automatically via the module's functions/ dir
  local compdir="${_DOTFILES_MODULE_ROOT}/functions"
  local tool subcmd compfile generated=0

  for tool in ${(@k)DOTFILES_COMPLETIONS}; do
    (( ${+commands[$tool]} )) || continue
    subcmd="${DOTFILES_COMPLETIONS[$tool]}"
    compfile="${compdir}/_${tool}"
    [[ -e $compfile && $compfile -nt ${commands[$tool]} ]] && continue

    [[ -d $compdir ]] || mkdir -p "$compdir" || return 1
    if ${commands[$tool]} ${(z)subcmd} >| "$compfile"; then
      print -P "%F{244}* Regenerated completions for %f%B${tool}%b%F{244}.%f" >/dev/tty
      generated=1
    fi
  done

  (( generated )) && (( $+functions[compinit] )) && \
    compinit -u -d "${ZSH_COMPDUMP:-${ZDOTDIR:-$HOME}/.zcompdump}"
}
unset DOTFILES_COMPLETIONS
