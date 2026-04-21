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

## Tool shell integrations — deferred to first prompt so compinit has run.
# Pre-declare DOTFILES_HOOKS in ~/.zshenv to add your own or override defaults.
# Key = binary name, value = init command. Hook is cached and recompiled when binary changes.
typeset -gA DOTFILES_HOOKS
: ${DOTFILES_HOOKS[zoxide]:="zoxide init zsh"}
: ${DOTFILES_HOOKS[direnv]:="direnv hook zsh"}

_dotfiles_hooks_init() {
  add-zsh-hook -d precmd _dotfiles_hooks_init
  zmodload -F zsh/stat b:zstat

  local binary cmd hook
  for binary in ${(k)DOTFILES_HOOKS}; do
    (( ${+commands[$binary]} )) || continue
    cmd=${DOTFILES_HOOKS[$binary]}
    hook="${XDG_CACHE_HOME:-$HOME/.cache}/dotfiles-hook-${binary}.zsh"
    if [[ ! -s $hook ]] || {
      local -a t  # t[1]=binary mtime, t[2]=hook mtime
      zstat -A t +mtime ${commands[$binary]} $hook 2>/dev/null && [[ ${t[1]} -gt ${t[2]} ]]
    }; then
      ${(z)cmd} >! "$hook" && zcompile -UR "$hook"
    fi
    source "$hook"
  done
  unset -f _dotfiles_hooks_init
  unset DOTFILES_HOOKS
}
add-zsh-hook precmd _dotfiles_hooks_init
