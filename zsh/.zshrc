# Customize prompt to include user (%n), host (%m), directory (%~), and prompt style (%#)
PROMPT='%F{green}%n@%m%f %F{blue}%~%f %# '

# Alias to list with colors enabled
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Start fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
