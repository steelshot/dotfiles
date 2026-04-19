# shellcheck shell=zsh
skip_global_compinit=1  # prevent /etc/zshrc from running compinit before zim does

# CLI tools to generate and cache zsh completions for.
# Format: tool -> arguments passed to tool to produce zsh completion script
typeset -gA _ZSH_TOOL_COMPLETIONS=(
  yq      "shell-completion zsh"
  gh      "completion -s zsh"
  helm    "completion zsh"
)
