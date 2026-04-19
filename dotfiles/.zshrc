# -----------------
# p10k configuration
# -----------------

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
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

# CLI tools to generate and cache zsh completions for.
# Format: tool -> arguments passed to tool to produce zsh completion script
typeset -gA _ZSH_TOOL_COMPLETIONS=(
  yq      "shell-completion zsh"
  gh      "completion -s zsh"
  helm    "completion zsh"
)

# Append `../` to your input for each `.` you type after an initial `..`
#zstyle ':zim:input' double-dot-expand yes

# Set a custom terminal title format using prompt expansion escape sequences.
# See http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html#Simple-Prompt-Escapes
# If none is provided, the default '%n@%m: %~' is used.
#zstyle ':zim:termtitle' format '%1~'

# Use eza instead of ls -AF for magic-enter directory listing (falls back to ls if eza not installed)
zstyle ':zim:magic-enter' commands \
    'if (( ${#dirstack} )) print -P %F{244}${${(Dq+)dirstack}//\//%f\/%F{244}}%f' \
    '(( ${+commands[eza]} )) && eza -A --group-directories-first || ls -AF' \
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
  source "${ZIM_HOME}/zimfw.zsh" init
fi

# Initialize modules.
source "${ZIM_HOME}/init.zsh"

# ------------------------------
# Post-init module configuration
# ------------------------------

# set descriptions format to enable group support
zstyle -d ':completion:*' format
zstyle ':completion:*:descriptions' format '[%d]'

# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no

# disable sort when completing git checkout
zstyle ':completion:*:git-checkout:*' sort false

# switch groups with < and > instead of F1/F2
zstyle ':fzf-tab:*' switch-group '<' '>'

# press tab to accept completion instead of enter
zstyle ':fzf-tab:*' fzf-flags --bind=tab:accept

# preview directory's content with eza when completing cd (falls back to ls)
zstyle ':fzf-tab:complete:cd:*' fzf-preview '(( ${+commands[eza]} )) && eza -1 --color=always $realpath || ls -1 $realpath'

# Initialize zoxide (must be after compinit)
(( ${+commands[zoxide]} )) && eval "$(zoxide init zsh)"
