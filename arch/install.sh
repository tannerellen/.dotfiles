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

# Optional firmware packages (not needed except to get rid of warnings when building)
paru -S mkinitcpio-firmware

# Important utilities
sudo pacman -S stow zip unzip man-db starship dosfstools mtools fzf ripgrep
# When using stow becuase everything is in a subdirectory you must use the --target flag
# cd ~/.dotfiles/arch
# stow --target=$HOME

# Text editors
sudo pacman -S neovim vim

# Hyprland packages
paru -S hyprland-git xdg-desktop-portal-hyprland-git hyprlock-git hyprpaper-git hypridle-git hyprpicker-git

# Pyprland - hyprland plugins
paru -S pyprland-git

# Additional portals (gtk used as filepicker as hyprland portal doesn't support file pickers)
sudo pacman -S xdg-desktop-portal-gtk

# Authentication agent
# https://wiki.archlinux.org/title/Polkit
sudo pacman -S polkit-gnome

# QT
sudo pacman -S qt5-wayland qt6-wayland

# GTK2 for some apps (like dadroit)
sudo pacman -S gtk2

# Fonts
paru -S ttf-ubuntu-font-family ttf-firacode-nerd ttf-ubuntu-mono-nerd ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk noto-fonts-extra noto-fonts nerd-fonts-noto-sans-mono

# Theme
sudo pacman -S breeze breeze5 breeze-gtk breeze-icons
sudo pacman -S gnome-themes-extra
sudo pacman -S nwg-look qt5ct qt6ct
# sudo pacman -S xsettingsd

# Xsettings for xwayland apps
sudo pacman -S xorg-xrdb

# Screen capture
sudo pacman -S grim slurp
paru -S satty-git # using git version becuase it fixes a bug with copy as of 2024-09-10

# Notification daemon
sudo pacman -S swaync

# Display manager
sudo pacman -S sddm sddm-kcm --needed qt6-5compat qt6-declarative qt6-svg
sudo git clone https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme/
sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
sudo sed -i 's/Current=/sddm-astronaut-theme/' /usr/lib/sddm/sddm.conf.d/default.conf
sudo systemctl enable sddm.service

# Audio
# sudo pacman -S pipewire wireplumber # Should be installed from arch-install
sudo pacman -S pavucontrol easyeffects pamixer wob --needed pipewire wireplumber
paru -S cava

# Create listener file for wob volume indicator
mkfifo /tmp/wobpipe

# Video and GPU
# https://wiki.archlinux.org/title/Vulkan
# https://wiki.archlinux.org/title/OpenGL
# https://wiki.archlinux.org/title/AMDGPU
sudo pacman -S wlr-randr vulkan-icd-loader lib32-vulkan-icd-loader vulkan-radeon lib32-vulkan-radeon mesa lib32-mesa libva-mesa-driver

# AMD GPU Overclocking
paru -S lact
sudo systemctl enabled --now lactd

# Pipewire libcamera (for webcam capture using pipewire)
# sudo pacman -S pipewire-libcamera # Hyprland and wlr desktop portals currently don't support camera capture so don't install until they do 

# Bluetooth
sudo pacman -S bluez bluez-utils blueman
sudo systemctl enable --now bluetooth.service

# Edit bluetooth settings to allow for bluetooth controllers
sudo sed -i 's/#ClassicBondedOnly=true/ClassicBondedOnly=false/' /etc/bluetooth/input.conf

# Waybar
paru -S waybar-cava

# Application launcher
paru -S fuzzel-git

# File manager
sudo pacman -S thunar gvfs

# wlogout
paru -S wlogout

# Clipboard
paru -S wl-clipboard clipse

# Nodejs with nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvim install v20.17.0

# Resource usage tools
sudo pacman -S bottom btop htop

# Image viewers
sudo pacman -S imv
paru -S coreimage

# Video / screencasts
paru -S wf-recorder

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
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# Backups
sudo pacman -S timeshift xorg-xhost

# Network discover mdns
sudo pacman -S avahi nss-mdns
sudo systemctl enable --now avahi-daemon.service
sudo sed -i 's/mymachines /mymachines mdns_minimal [NOTFOUND=return] /' /etc/nsswitch.conf

# Printing
# https://wiki.archlinux.org/title/CUPS
sudo pacman -S cups ghostscript
sudo systemctl enable --now cups.service

# Sensors and fans
sudo pacman -S lm_sensors
sudo sensors-detect --auto

# i2c / rgb
sudo pacman -S i2c-tools
# enable i2c bus for rgb
# echo 'i2c-dev' | sudo tee -a /etc/modules-load.d/i2c-dev.conf

# Software to use loopback video device to share screen as second camera
# https://www.math.cmu.edu/~gautam/sj/blog/20220326-zoom-wayland.html
sudo pacman -S v4l2loopback-utils v4l2loopback-dkms linux-headers
# Launch obs and click "Start Virtual Camera"

##### User apps #####
sudo pacman -S lazygit imagemagick obs-studio mpv thunderbird vlc remmina gtk-vnc transmission-gtk p7zip gamescope syncthing gparted
paru -S 1password-beta slack-desktop zoom wlrobs ungoogled-chromium prusa-slicer cura vesktop webapp-manager localsend vscode kalc obsidian wayvnc parsec digikam balena-etcher amdgpu_top-bin wlvncc-git

flatpak install --user flatseal
# Pipewire volume control
flatpak install flathub com.saivert.pwvucontrol
# Upscaler
flatpak install --user flathub io.gitlab.theevilskeleton.Upscaler
# Gimp Beta
flatpak install --user https://flathub.org/beta-repo/appstream/org.gimp.GIMP.flatpakref
# Bottles
flatpak install --user com.usebottles.bottles

# Dadroit json viewer
cd ~
curl -LO https://dadroit.com/releases/lnx/DadroitJSONViewer.AppImage
chmod +x DadroitJSONViewer.AppImage
sudo mv DadroitJSONViewer.AppImage /usr/local/bin/dadroit


# AWS CLI
cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip
rm -rf aws
# Authenticat with:
aws configure

##### Games and emulation #####
# https://wiki.archlinux.org/title/Steam
# https://github.com/Ryujinx/Ryujinx/wiki/Ryujinx-Setup-&-Configuration-Guide
sudo pacman -S steam
paru -S ryujinx-bin

##### Cleanup and after install items #####
systemctl --user enable --now syncthing.service

# Edit Prusa Slicer desktop file so it opens at scale factor of 1
sudo sed -i 's/Exec=/Exec=env GDK_SCALE=1 /' /usr/share/applications/PrusaSlicer.desktop

# Ryujinx scale factor - Pass through app as it doesn't seem to read from global env variable
sudo sed -i 's|Exec=Ryujinx.sh|Exec=bash -c '\''AVALONIA_SCREEN_SCALE_FACTORS="DP-1=1.875000" Ryujinx.sh'\''|' /usr/share/applications/Ryujinx.desktop

# Update man page caches
sudo mandb
