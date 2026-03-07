# Enable completion system
autoload -Uz compinit
compinit

# Starship
export STARSHIP_CONFIG="$HOME/.config/starship/starship.toml"
eval "$(starship init zsh)"

# Autosuggestions plugin
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Keybindings
bindkey '^I' autosuggest-accept      # Tab → accept grey suggestion
bindkey '^[[Z' expand-or-complete    # Shift+Tab → normal completion

# Aliases
alias vim="nvim"
alias ls="ls --color=auto"

