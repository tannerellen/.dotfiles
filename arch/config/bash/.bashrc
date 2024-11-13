#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Default editor
export EDITOR=nvim

eval "$(starship init bash)"

# Set up keychain for ssh key password management
# https://wiki.archlinux.org/title/SSH_keys
# eval $(keychain --eval --noask --quiet ~/.ssh/github ~/.ssh/seedcode-tanner)
