#!/bin/bash
sudo pacman -S tlp tlp-rdw
sudo systemctl enable tlp.service
flatpak install --user com.github.d4nj1.tlpui
