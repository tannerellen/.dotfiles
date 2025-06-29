#!/bin/bash/

# Stow specific dotfiles
cd ~/.dotfiles/arch/desktop
stow --target=$HOME *

# AMD GPU Overclocking
paru -S lact --noconfirm

sudo systemctl enable --now lactd

