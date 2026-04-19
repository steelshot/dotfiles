# shellcheck shell=zsh

# -----------------
# p10k configuration
# -----------------

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
# shellcheck disable=SC2296
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  # shellcheck source=/dev/null
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# shellcheck source=/dev/null
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# -----------------
# Zsh configuration
# -----------------


# Set editor default keymap to emacs (`-e`) or vi (`-v`)
bindkey -e

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

# Prompt for spelling correction of commands.
#setopt CORRECT

# Customize spelling correction prompt.
#SPROMPT='zsh: correct %F{red}%R%f to %F{green}%r%f [nyae]?'

# -----------------
# Zim configuration
# -----------------

# Use degit instead of git as the default tool to install and update modules.
zstyle ':zim:zmodule' use 'degit'

# Disable version auto-check
zstyle ':zim' disable-version-check yes

# --------------------
# Module configuration
# --------------------

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

# Use eza instead of ls -AF for magic-enter directory listing
zstyle ':zim:magic-enter' commands \
    'if (( ${#dirstack} )) print -P %F{244}${${(Dq+)dirstack}//\//%f\/%F{244}}%f' \
    'eza -A --group-directories-first' \
    'git --no-pager status -sb --untracked-files=no 2>/dev/null'

# ------------------
# Initialize modules
# ------------------

ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# Download zimfw plugin manager if missing.
if [[ ! -e "${ZIM_HOME}/zimfw.zsh" ]]; then
  if (( ${+commands[curl]} )); then
    curl -fsSL --create-dirs -o "${ZIM_HOME}/zimfw.zsh" \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  else
    mkdir -p "${ZIM_HOME}" && wget -nv -O "${ZIM_HOME}/zimfw.zsh" \
        https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
  fi
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! "${ZIM_HOME}/init.zsh" -nt "${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc}" ]]; then
  # shellcheck source=/dev/null
  source "${ZIM_HOME}/zimfw.zsh" init
fi

# Initialize modules.
# shellcheck source=/dev/null
source "${ZIM_HOME}/init.zsh"

# ------------------------------
# Post-init module configuration
# ------------------------------

# set descriptions format to enable group support
zstyle -d ':completion:*' format
zstyle ':completion:*:descriptions' format '[%d]'

# set list-colors to enable filename colorizing
# shellcheck disable=SC2296,SC2086
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# disable sort when completing git checkout
zstyle ':completion:*:git-checkout:*' sort false

# switch groups with < and > instead of F1/F2
zstyle ':fzf-tab:*' switch-group '<' '>'

# press tab to accept completion instead of enter
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept

# preview directory's content with eza when completing cd
# shellcheck disable=SC2016
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Initialize zoxide (must be after compinit)
(( ${+commands[zoxide]} )) && eval "$(zoxide init zsh)"
