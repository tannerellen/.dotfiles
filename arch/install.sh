#!/bin/bash

# Kitty terminal if it isn't already installed
sudo pacman -S kitty

# Add pictures folder
mkdir ~/Pictures

# Install ssh
mkdir ~/.ssh/
sudo pacman -S openssh

# Add user to input group so keyboard status works in waybar
sudo usermod -aG input $(whoami)

# Add user to the i2c group to control i2c devices
# sudo usermod -aG i2c $(whoami)

# Add aur helpers
sudo pacman -S --needed base-devel git

cd ~
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

cd ~
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# Hyprland packages
yay -S hyprland-git xdg-desktop-portal-hyprland-git hyprlock-git hyprpaper-git hypridle-git hyprpicker-git

# Additional portals (gtk used as filepicker as hyprland portal doesn't support file pickers)
sudo pacman -S xdg-desktop-portal-gtk

# Authentication agent
sudo pacman -S polkit-kde-agent

# QT
sudo pacman -S qt5-wayland qt6-wayland

# Fonts
yay -S ttf-ubuntu-font-family ttf-firacode-nerd ttf-ubuntu-mono-nerd ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk noto-fonts-extra noto-fonts nerd-fonts-noto-sans-mono

# Theme
sudo pacman -S breeze breeze5 breeze-gtk breeze-icons
sudo pacman -S gnome-themes-extra
sudo pacman -S nwg-look qt5ct qt6ct
sudo pacman -S xsettingsd

# Xsettings for xwayland apps
sudo pacman -S xorg-xrdb

# Screen capture
sudo pacman -S grim slurp satty

# Notification daemon
sudo pacman -S swaync

# Display manager
sudo pacman -S sddm sddm-kcm --needed qt6-5compat qt6-declarative qt6-svg
sudo systemctl enable --now sddm.service
sudo git clone https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme/
sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
echo "[Theme]
Current=sddm-astronaut-theme" | sudo tee /usr/lib/sddm/sddm.conf.d/default.conf

# Audio
# sudo pacman -S pipewire wireplumber # Should be installed from arch-install
sudo pacman -S pipewire wireplumber pavucontrol pamixer easyeffects
yay -S cava

# Video
# https://wiki.archlinux.org/title/Vulkan
# https://wiki.archlinux.org/title/OpenGL
sudo pacman -S wlr-randr vulkan-icd-loader lib32-vulkan-icd-loader vulkan-radeon lib32-vulkan-radeon mesa lib32-mesa

# Bluetooth
sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable --now bluetooth.service

# Bluetooth gamepad
# yay -S xpadneo-dkms # Problems with 8bitDo bluetooth connection loop so using wired only for now

# Waybar
yay -S waybar-cava

# File manager
sudo pacman -S thunar

# wlogout
yay -S wlogout

# Clipboard
yay -S wl-clipboard clipse

# Nodejs with nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvim install v20.17.0

# Resource usage tools
sudo pacman -S bottom btop htop

# Image viewers
sudo pacman -S imv
yay -S coreimage

# Video / screencasts
yay -S wf-recorder

# RGB control
sudo pacman -S openrgb

# Neofetch alternative since it is no longer maintained
sudo pacman -S fastfetch

# jq for processing json
sudo pacman -S jq

# Keyring / Passwords
# https://wiki.archlinux.org/title/GNOME/Keyring
sudo pacman -S gnome-keyring libsecret seahorse
systemctl --user enable gcr-ssh-agent.socket
systemctl --user start gcr-ssh-agent.socket

# Fuse required for app images
sudo pacman -S fuse2

# Install flatpak
sudo pacman -S flatpak

# Pyprland - hyprland plugins
yay -S pyprland

# Backups
sudo pacman -S timeshift xorg-xhost

# Network discover mdns
sudo pacman -S avahi nss-mdns
sudo systemctl start avahi-daemon.service
sudo systemctl enable avahi-daemon.service
sudo sed -i 's/mymachines /mymachines mdns_minimal [NOTFOUND=return] /' /etc/nsswitch.conf

# Printing
sudo pacman -S cups ghostscript
sudo systemctl start cups.service
sudo systemctl enable cups.service

# Sensors and fans
sudo pacman -S lm_sensors
sudo sensors-detect --auto

# i2c / rgb
sudo pacman -S i2c-tools
# enable i2c bus for rgb
# echo 'i2c-dev' | sudo tee -a /etc/modules-load.d/i2c-dev.conf

##### User apps #####
sudo pacman -S lazygit unzip imagemagick obs-studio mpv thunderbird vlc remmina gtk-vnc transmission-gtk p7zip gamescope syncthing
yay -S 1password-beta-bin slack-desktop-bin gimp-devel zoom-bin wlrobs ungoogled-chromium-bin prusa-slicer cura-bin bluemail-bin vesktop-bin webapp-manager-bin localsend-bin vscode-bin kalc-bin obsidian-bin wayvnc parsec-bin digikam balena-etcher

flatpak install --user flatseal
# Upscaler
flatpak install --user flathub io.gitlab.theevilskeleton.Upscaler
# Gimp Beta
flatpak install --user https://flathub.org/beta-repo/appstream/org.gimp.GIMP.flatpakref

# AWS CLI
cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip
rm -rf aws

##### Games and emulation #####
# https://wiki.archlinux.org/title/Steam
# https://github.com/Ryujinx/Ryujinx/wiki/Ryujinx-Setup-&-Configuration-Guide
sudo pacman -S steam
yay -S ryujinx

##### Cleanup and after install items #####
systemctl --user enable syncthing.service
systemctl --user start syncthing.service

# Edit Prusa Slicer desktop file so it opens at scale factor of 1
sudo sed -i 's/Exec=/Exec=env GDK_SCALE=1 /' /usr/share/applications/PrusaSlicer.desktop
