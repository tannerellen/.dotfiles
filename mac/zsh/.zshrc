# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

USE_POWERLINE="true"
# Customize prompt to include user (%n), host (%m), directory (%~), and prompt style (%#)
PROMPT='%F{green}%n@%m%f %F{blue}%~%f %# '

# Alias to list with colors enabled
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Start fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

alias sd="cd \$(find * -type d | fzf)"
bind '"\C-f":"vim $(find * -type f | fzf)\n"' 

source /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
