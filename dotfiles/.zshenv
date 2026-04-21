skip_global_compinit=1

# Prepend user binary dirs if not already in PATH
path=($HOME/.local/bin(N-/) $HOME/bin(N-/) $path)
typeset -U path

# Pre-declare customisation maps. Add entries here to override/extend defaults.
typeset -gA DOTFILES_ALIASES     # alias name → command (skipped if binary missing)
typeset -gA DOTFILES_SUGGEST     # legacy cmd → pipe-separated modern candidates
typeset -gA DOTFILES_COMPLETIONS # binary → completion subcommand (cached to functions/)
typeset -gA DOTFILES_HOOKS       # binary → init command (cached, runs after compinit)
