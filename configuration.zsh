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

## Modules
zmodload zsh/parameter  # exposes $history, $HISTCMD
zmodload zsh/datetime   # strftime, $EPOCHSECONDS

## Autoloaded functions
autoload -Uz add-zsh-hook

## Changing directories
setopt auto_cd           # type a directory name to cd into it
setopt auto_pushd        # cd pushes old directory onto the stack
setopt pushd_ignore_dups # don't push duplicate directories onto the stack
setopt pushd_silent      # don't print the stack after pushd or popd
setopt pushd_to_home     # pushd with no args acts like pushd ${HOME}
autoload -Uz is-at-least && is-at-least 5.8 && setopt cd_silent  # no output after cd (zsh >= 5.8)

## Expansion and globbing
setopt extended_glob        # treat #, ~, and ^ as filename glob patterns
setopt interactive_comments # allow # comments in the interactive shell

## Input/output
setopt no_clobber # disallow > to overwrite existing files; use >| instead

## Job control
setopt long_list_jobs # list jobs in verbose format by default
setopt no_bg_nice     # don't lower priority of background jobs
setopt no_check_jobs  # no job status report on shell exit
setopt no_hup         # don't send SIGHUP to jobs on shell exit

HISTFILE=/dev/null
(( HISTSIZE < 50000 )) && HISTSIZE=50000
SAVEHIST=0

setopt hist_verify

## Module pre-init configuration

# zsh-bash-completions-fallback (https://github.com/3v1n0/zsh-bash-completions-fallback)
ZSH_BASH_COMPLETIONS_FALLBACK_LAZYLOAD_DISABLE=true

# zsh-syntax-highlighting (https://github.com/zsh-users/zsh-syntax-highlighting)
# See https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/docs/highlighters.md
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)

# zsh-autosuggestions (https://github.com/zsh-users/zsh-autosuggestions)
ZSH_AUTOSUGGEST_STRATEGY=(history completion)  # fall back to completion when no history match
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20             # disable suggestions for large pastes
