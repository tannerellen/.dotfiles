#!/bin/bash/

# Update boot loading.conf 
echo -e "timeout 1\nconsole-mode keep" | sudo tee /boot/loader/loader.conf > /dev/null

# Stow specific dotfiles
cd ~/.dotfiles/arch/desktop
stow --target=$HOME *

# AMD GPU Overclocking
paru -S lact --noconfirm

sudo systemctl enable --now lactd

