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
function _zsh_history() {
  # parse arguments and remove from $@
  local -a clear purge stamp help
  local REPLY
  zparseopts -E -D c=clear C=purge f=stamp E=stamp i=stamp t:=stamp h=help -help=help

  if [[ -n "$help" ]]; then
    print -P "%Busage:%b history [options] [range]"
    print
    print -P "%BOptions:%b"
    print "  -c           archive history to ~/.cache/zsh_history/ and clear"
    print "  -C           delete history and remove all archived snapshots"
    print "  -f           show timestamps in mm/dd/yyyy format"
    print "  -E           show timestamps in dd.mm.yyyy format"
    print "  -i           show timestamps in yyyy-mm-dd format"
    print "  -t FORMAT    show timestamps in a custom strftime FORMAT"
    print "  -h, --help   show this help"
    print
    print -P "%BRange:%b"
    print "  history          show all history"
    print "  history N        show last N entries"
    print "  history M N      show entries M through N"
    return 0
  fi

  local archive_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh_history"

  if [[ -n "$purge" ]]; then
    # -C: delete live history AND all archived snapshots
    print -nu2 "This will permanently delete your history and all archived snapshots. Are you sure? [y/N] "
    # shellcheck disable=SC2162
    builtin read -E
    [[ "$REPLY" = [yY] ]] || return 0

    true >| "$HISTFILE"
    fc -p "$HISTFILE"
    if [[ -d "$archive_dir" ]]; then
      rm -f "${archive_dir}"/*.hst
      print -Pu2 "%F{green}History and all snapshots deleted.%f"
    else
      print -Pu2 "%F{green}History deleted.%f"
    fi

  elif [[ -n "$clear" ]]; then
    # -c: archive current history to a timestamped snapshot, then clear
    print -nu2 "Archive and clear history? [y/N] "
    # shellcheck disable=SC2162
    builtin read -E
    [[ "$REPLY" = [yY] ]] || return 0

    mkdir -p "$archive_dir"
    local snapshot
    snapshot="${archive_dir}/$(strftime '%Y-%m-%d_%H-%M-%S' $EPOCHSECONDS).hst"
    cp "$HISTFILE" "$snapshot"

    true >| "$HISTFILE"
    fc -p "$HISTFILE"

    print -Pu2 "%F{green}History archived to ${snapshot} and cleared.%f"

  elif [[ $# -eq 0 ]]; then
    # if no arguments provided, show full history starting from 1
    builtin fc "${stamp[@]}" -l 1
  else
    # otherwise, run `fc -l` with a custom range
    builtin fc "${stamp[@]}" -l "$@"
  fi
}

# Timestamp format
case ${HIST_STAMPS-} in
  "mm/dd/yyyy") alias history='_zsh_history -f' ;;
  "dd.mm.yyyy") alias history='_zsh_history -E' ;;
  "yyyy-mm-dd") alias history='_zsh_history -i' ;;
  "") alias history='_zsh_history' ;;
  *) alias history="_zsh_history -t '\$HIST_STAMPS'" ;;
esac

## History file configuration
(( ! ${+HISTFILE} )) && HISTFILE="$HOME/.zsh_history"
(( HISTSIZE < 50000 )) && HISTSIZE=50000
(( SAVEHIST < 10000 )) && SAVEHIST=10000

## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_find_no_dups      # don't display duplicates when searching history
setopt hist_ignore_all_dups   # remove all older duplicate entries from history
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

## Don't save commands that were not found
zshaddhistory() { [[ $? -ne 127 ]]; }

## Interactively delete history entries using fzf (originally zimfw/smite)
smite() {
  if ! command -v fzf >/dev/null 2>&1; then
    print -Pu2 "%F{red}smite: fzf is required but not found%f"
    return 1
  fi

  local opts=(-I)
  if [[ $1 == -a ]]; then
    opts=()
  elif [[ -n $1 ]]; then
    print -Pu2 "%F{red}usage: smite [-a]%f"
    print -u2 "  -a  show all history (default: current session only)"
    return 2
  fi

  local hist_to_delete HISTORY_IGNORE
  fc -lrn "${opts[@]}" 1 | fzf --no-sort --multi | while IFS= read -r hist_to_delete; do
    print -P "%F{244}Removing history entry \"%f${hist_to_delete}%F{244}\"%f"
    # shellcheck disable=SC2034,SC2296
    HISTORY_IGNORE="${(b)hist_to_delete}"
    fc -W
    fc -p "${HISTFILE}" "${HISTSIZE}" "${SAVEHIST}"
  done
}
