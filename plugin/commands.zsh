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

# shellcheck disable=SC1036,SC1088  # (N) is a valid zsh glob qualifier, not a syntax error
# shellcheck disable=SC2154          # zimfw/_zimfw_orig are assigned via functions[] zsh builtin

# Capture the dotfiles source directory at plugin load time (0:h = plugin/, :h again = repo root)
_ZSH_DOTFILES_SRC="${0:h:h}/dotfiles"

## Purge all zsh/zimfw generated and cached files, leaving dotfiles and history intact.
## Re-opening the shell will trigger a full zimfw reinstall.
zpurge() {
  local zdotdir="${ZDOTDIR:-$HOME}"
  local zim_home="${ZIM_HOME:-${zdotdir}/.zim}"
  local cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}"
  local restart=0
  [[ $1 == -r ]] && { restart=1; shift; }

  local -a targets=()
  [[ -d "$zim_home" ]] && targets+=("$zim_home")
  targets+=("${zdotdir}"/.zcompdump*(N))
  targets+=("${cache_dir}"/p10k-*(N))
  [[ -d "${cache_dir}/gitstatus" ]] && targets+=("${cache_dir}/gitstatus")
  targets+=("${zdotdir}"/**/*.zwc(N) "${HOME}"/*.zwc(N))

  if (( ${#targets} == 0 )); then
    print -P "%F{244}Nothing to purge.%f"
    return 0
  fi

  print -n "Purge all zimfw and zsh cached files? [y/N] "
  local REPLY
  # shellcheck disable=SC2162
  read -E
  [[ "$REPLY" = [yY] ]] || return 0

  local failed=0
  for t in "${targets[@]}"; do
    rm -rf "$t" || { print -Pu2 "%F{red}zpurge: failed to remove ${t}%f"; failed=1; }
  done

  (( failed )) && return 1
  print -P "%F{green}Purged.%f %F{244}Start a new shell to trigger a fresh zimfw install.%f"
  (( restart )) && exec zsh
}

## Replace local dotfiles with the versions from the dotfiles module.
## Always creates a timestamped backup before overwriting anything.
zdotfiles() {
  local src="$_ZSH_DOTFILES_SRC"
  local snapshot
  # shellcheck disable=SC2034
  snapshot="${XDG_DATA_HOME:-$HOME/.local/share}/dotfiles.old/$(strftime '%Y-%m-%d_%H-%M-%S' $EPOCHSECONDS)"

  if [[ ! -d "$src" ]]; then
    print -u2 "zdotfiles: dotfiles source not found: ${src}"
    return 1
  fi

  local -a dotfiles=("${src}"/.*(.N))
  if (( ${#dotfiles} == 0 )); then
    print "zdotfiles: no dotfiles found in ${src}."
    return 1
  fi

  print -n "Replace local dotfiles with module versions? [y/N] "
  local REPLY
  # shellcheck disable=SC2162
  read -E
  [[ "$REPLY" = [yY] ]] || return 0

  print -n "This is irreversible (a backup will be created). Type YES to confirm: "
  # shellcheck disable=SC2162
  read -E
  [[ "$REPLY" = "YES" ]] || { print -P "%F{yellow}Aborted.%f"; return 0; }

  mkdir -p "$snapshot"
  local failed=0
  for f in "${dotfiles[@]}"; do
    local name="${f:t}"
    [[ -e "$HOME/$name" ]] && cp "$HOME/$name" "${snapshot}/${name}"
    cp "$f" "$HOME/$name" || { print -u2 "zdotfiles: failed to install ~/${name}"; failed=1; }
  done

  (( failed )) && return 1
  print -P "%F{green}Replaced.%f %F{244}Backup saved to ${snapshot}%f"
  print -P "%F{244}Restart your shell to apply changes.%f"
}

# Hook into zimfw by wrapping it after zim init defines it.
# Adds 'purge' and 'dotfiles' as extra subcommands.
if (( $+functions[zimfw] )); then
  # shellcheck disable=SC2296
  functions[_zimfw_orig]=${functions[zimfw]}
  zimfw() {
    if [[ $1 == purge ]]; then
      zpurge "${@:2}"
    elif [[ $1 == dotfiles ]]; then
      zdotfiles "${@:2}"
    elif [[ $# -eq 0 || $1 == help || $1 == -h || $1 == --help ]]; then
      _zimfw_orig "$@" | sed \
        -e '/^  check[[:space:]]/i\  purge             Purge all zimfw and zsh generated/cached files. Use -r to restart.' \
        -e '/^  check[[:space:]]/i\  dotfiles          Replace local dotfiles with module versions (backup created automatically).'
    else
      _zimfw_orig "$@"
    fi
  }
fi
