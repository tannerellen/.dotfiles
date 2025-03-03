#!/bin/bash

# Make sure the basics are installed to continue running this script
sudo pacman -S --needed kitty git neovim vim stow zip unzip base-devel --noconfirm

# Clone dotfiles
cd ~
git clone https://github.com/tannerellen/.dotfiles.git
rm ~/.bashrc

cd ~/.dotfiles/
stow wallpapers
cd ~/.dotfiles/shared/config
stow --target=$HOME *
cd ~/.dotfiles/arch/config
stow --target=$HOME *
cd ~/.dotfiles/arch/themes
stow --target=$HOME *
cd ~/.dotfiles/arch/system
stow --target=/ *

# Add aur helpers
sudo pacman -S --needed base-devel git --noconfirm
cd ~
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si

# Add pictures folder
mkdir -p ~/Pictures

# Install ssh
mkdir -p ~/.ssh/
sudo pacman -S openssh --noconfirm

# Add user to input group so keyboard status works in waybar
sudo usermod -aG input $(whoami)

# Add user to uucp group to interact with usb serial devices (arduino)
sudo usermod -aG uucp $(whoami)

# Add user to the i2c group to control i2c devices
# sudo usermod -aG i2c $(whoami)

# Optional firmware packages (not needed except to get rid of warnings when building)
paru -S mkinitcpio-firmware

# Important utilities
sudo pacman -S man-db starship dosfstools mtools brightnessctl fzf ripgrep jq fastfetch bottom btop htop --noconfirm
# When using stow becuase everything is in a subdirectory you must use the --target flag
# cd ~/.dotfiles/arch
# stow --target=$HOME

# Hyprland packages and plugins
sudo pacman -S hyprland xdg-desktop-portal-hyprland hyprlock hyprpaper hypridle hyprpicker --noconfirm

# Additional portals (gtk used as filepicker as hyprland portal doesn't support file pickers)
sudo pacman -S xdg-desktop-portal-gtk

# Authentication agent
# https://wiki.archlinux.org/title/Polkit
sudo pacman -S polkit-gnome --noconfirm


# QT
sudo pacman -S qt5-wayland qt6-wayland --noconfirm


# GTK2 for some apps (like dadroit)
sudo pacman -S gtk2 --noconfirm


# Fonts
paru -S ttf-ubuntu-font-family ttf-firacode-nerd ttf-ubuntu-mono-nerd ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk noto-fonts-extra noto-fonts nerd-fonts-noto-sans-mono

# Theme
sudo pacman -S breeze breeze5 breeze-gtk breeze-icons gnome-themes-extra nwg-look qt5ct qt6ct --noconfirm

# Use libadwaita for gtk4 without needing adwaita theme
paru -S libadwaita-without-adwaita-git


# Xsettings for xwayland apps used to handle dpi settings for proper sizing
sudo pacman -S xorg-xrdb --noconfirm


# Screen capture
sudo pacman -S grim slurp --noconfirm

paru -S satty-git # using git version becuase it fixes a bug with copy as of 2024-09-10

# Notification daemon
sudo pacman -S swaync --noconfirm


# Display manager
sudo pacman -S sddm sddm-kcm --needed qt6-5compat qt6-declarative qt6-svg --noconfirm

sudo git clone https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme/
sudo cp /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
sudo sed -i 's/Current=/Current=sddm-astronaut-theme/' /usr/lib/sddm/sddm.conf.d/default.conf
sudo systemctl enable sddm.service

# Audio
# pipewire and wireplumber Should be installed from arch-install
# lsp-plugins and calf are easyeffects dependencies
sudo pacman -S pavucontrol easyeffects pamixer wob lsp-plugins calf --needed pipewire wireplumber --noconfirm

# Hide desktop entries for lsp-plugins so it doesn't flood app launchers
find /usr -name "*lsp_plug*desktop" 2>/dev/null | xargs -I {} sudo sh -c 'printf "\nNoDisplay=true\n" >> "{}"'

paru -S cava

# Create listener file for wob volume indicator
mkfifo /tmp/wobpipe

# Video and GPU
# https://wiki.archlinux.org/title/Vulkan
# https://wiki.archlinux.org/title/OpenGL
# https://wiki.archlinux.org/title/AMDGPU
sudo pacman -S wlr-randr vulkan-icd-loader lib32-vulkan-icd-loader vulkan-radeon lib32-vulkan-radeon mesa lib32-mesa libva-mesa-driver --noconfirm


# AMD GPU Overclocking
paru -S lact
sudo systemctl enable --now lactd

# Pipewire libcamera (for webcam capture using pipewire)
# sudo pacman -S pipewire-libcamera # Hyprland and wlr desktop portals currently don't support camera capture so don't install until they do 

# Bluetooth
sudo pacman -S bluez bluez-utils blueman --noconfirm
sudo systemctl enable --now bluetooth.service

# To pair bluetooth game controllers you will need to pair manually with bluetoothctl:
# bluetoothctl
# scan on
# pair MAC_ADDRESS
# connect MAC_ADDRESS
# trust MAC_ADDRESS


# Edit bluetooth settings to allow for bluetooth controllers
# sudo sed -i 's/#ClassicBondedOnly=true/ClassicBondedOnly=false/' /etc/bluetooth/input.conf

# Waybar
paru -S waybar-cava

# Application launcher
paru -S walker-bin
# paru -S fuzzel

# File manager
sudo pacman -S thunar gvfs --noconfirm


# wlogout
paru -S wlogout

# Clipboard
paru -S wl-clipboard clipse

# Nodejs with nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install v20.17.0

# Bun
paru -S bun-bin

# Image viewers
sudo pacman -S imv --noconfirm
paru -S coreimage

# Video / screencasts
paru -S wf-recorder wl-screenrec

# RGB control
sudo pacman -S openrgb --noconfirm

# Keyring / Passwords
# https://wiki.archlinux.org/title/GNOME/Keyring
sudo pacman -S gnome-keyring libsecret seahorse --noconfirm
systemctl --user enable --now gcr-ssh-agent.socket

# Fuse required for app images
sudo pacman -S fuse2 --noconfirm


# Backups
sudo pacman -S timeshift xorg-xhost --noconfirm


# Network discover mdns
sudo pacman -S avahi nss-mdns --noconfirm

sudo systemctl enable --now avahi-daemon.service
sudo sed -i 's/mymachines /mymachines mdns_minimal [NOTFOUND=return] /' /etc/nsswitch.conf

# Printing
# https://wiki.archlinux.org/title/CUPS
sudo pacman -S cups ghostscript --noconfirm
sudo systemctl enable --now cups.service

# SMB
sudo pacman -S smbclient

# Sensors and fans
sudo pacman -S lm_sensors --noconfirm
# sudo sensors-detect --auto

# i2c / rgb
sudo pacman -S i2c-tools --noconfirm
# enable i2c bus for rgb
# echo 'i2c-dev' | sudo tee -a /etc/modules-load.d/i2c-dev.conf

# Software to use loopback video device to share screen as second camera
# https://www.math.cmu.edu/~gautam/sj/blog/20220326-zoom-wayland.html
sudo pacman -S v4l2loopback-utils v4l2loopback-dkms linux-headers --noconfirm
# Launch obs and click "Start Virtual Camera"

##### User apps #####
sudo pacman -S firefox vivaldi lazygit yazi imagemagick gtk-vnc p7zip gamescope gamemode syncthing gparted steam arduino-cli arduino-ide --noconfirm
paru -S 1password-beta webapp-manager kalc wayvnc parsec amdgpu_top-bin wlvncc-git uxplay sunshine firefox-pwa-bin alvr-bin

# yazi support apps
sudo pacman -S --needed ffmpegthumbnailer zoxide p7zip jq ripgrep fd fzf imagemagick ueberzugpp chafa --noconfirm

# If installing obs with paru then make sure to install wlrobs since we are using the flatpak it's not necessary

# Install flatpak
sudo pacman -S flatpak --noconfirm
# Expose breeze gtk theme
flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
flatpak override --user --filesystem=xdg-config/gtk-4.0:ro

# Install flatpak stuff
flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install --user flatseal

flatpak install --user org.mozilla.Thunderbird
flatpak install --user com.obsproject.Studio
flatpak install --user com.slack.Slack
flatpak install --user us.zoom.Zoom
flatpak install --user dev.vencord.Vesktop
flatpak install --user com.prusa3d.PrusaSlicer
flatpak install --user com.ultimaker.cura
flatpak install --user org.localsend.localsend_app
flatpak install --user org.remmina.Remmina
flatpak install --user org.videolan.VLC
flatpak install --user io.mpv.Mpv
flatpak install --user io.github.celluloid_player.Celluloid
flatpak install --user org.kde.digikam
flatpak install --user flathub org.gnome.gedit
flatpak install --user com.transmissionbt.Transmission
flatpak install --user org.libreoffice.LibreOffice
flatpak install --user org.onlyoffice.desktopeditors
flatpak install --user org.gnome.SimpleScan
flatpak install --user org.shotcut.Shotcut
flatpak install --user org.gnome.gitlab.YaLTeR.VideoTrimmer
flatpak install --user com.rustdesk.RustDesk

# Pipewire volume control
flatpak install --user com.saivert.pwvucontrol

# Upscaler
flatpak install --user flathub io.gitlab.theevilskeleton.Upscaler
# Gimp Beta
flatpak install --user https://flathub.org/beta-repo/appstream/org.gimp.GIMP.flatpakref
# Bottles
flatpak install --user com.usebottles.bottles
# Heroic game launcher
flatpak install flathub com.heroicgameslauncher.hgl
# Emoji picker
flatpak install --user com.tomjwatson.Emote

## Update flatpak so it cleans up and installs any themes
flatpak update

# Ryujinx AppImage
# https://github.com/ryujinx-mirror/ryujinx
# cd ~
# curl -L -o Ryujinx https://github.com/ryujinx-mirror/ryujinx/releases/download/r.49574a9/ryujinx-r.49574a9-x64.AppImage
# chomd +x Ryujinx
# sudo mv Ryujinx /usr/local/bin
# curl -L -o Ryujinx.svg https://raw.githubusercontent.com/ryujinx-mirror/ryujinx/refs/heads/mirror/master/distribution/misc/Logo.svg
# sudo mv Ryujinx.svg /usr/share/pixmaps

# Ryujinx app
cd ~
curl -L -o ryujinx.tar.gz https://github.com/GreemDev/Ryujinx/releases/download/1.2.69/ryujinx-1.2.69-linux_x64.tar.gz
tar -xzf ryujinx.tar.g
rm ryujinx.tar.gz
mkdir -p .local/bin
mv publish .local/bin/ryujinx
sed -i 's/exec $COMMAND/exec env AVALONIA_SCREEN_SCALE_FACTORS='DP-1=1.8' $COMMAND/' ~/.local/bin/ryujinx/Ryujinx.sh

# Add ryujinx icon
cd ~
curl -L -o Ryujinx.svg https://raw.githubusercontent.com/ryujinx-mirror/ryujinx/refs/heads/mirror/master/distribution/misc/Logo.svg
mkdir -p .local/share/pixmaps
sudo mv Ryujinx.svg .local/share/pixmaps

##### Cleanup and after install items #####
systemctl --user enable --now syncthing.service

# Edit Prusa Slicer desktop file so it opens at scale factor of 1 (No longer needed becuase it looks like this is now being set by default on install)
# sudo sed -i 's/Exec=/Exec=env GDK_SCALE=1 /' /usr/share/applications/PrusaSlicer.desktop
# sudo sed -i 's/Exec=/Exec=env GDK_SCALE=1 /' ~/.local/share/flatpak/exports/share/applications/com.prusa3d.PrusaSlicer.desktop

# Update man page caches
sudo mandb

# AWS CLI
cd ~
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm awscliv2.zip
rm -rf aws
# Authenticate with:
# aws configure

# Salesforce dataloader
sudo pacman -S jdk-openjdk maven --noconfirm
cd ~
git clone https://github.com/forcedotcom/dataloader.git
cd dataloader
git submodule init
git submodule update
./dlbuilder.sh -n
mv target ~/sf-dataloader
cd ~
rm -rf dataloader
# To run the datloader
java -jar ~/sf-dataloader/dataloader-62.0.2.jar

# Firefox web extension stuff
# https://github.com/mozilla/web-ext
npm install --global web-ext
# Using web-ext
# https://extensionworkshop.com/documentation/develop/getting-started-with-web-ext/
# web-ext sign --channel=unlisted --api-key=$AMO_JWT_ISSUER --api-secret=$AMO_JWT_SECRET

# Optional config stuff
# Firefox custimzation
# SimpleFox: https://github.com/migueravila/SimpleFox
# GruvBox Material: https://addons.mozilla.org/en-US/firefox/addon/gruvbox-material-dark-official/
#
