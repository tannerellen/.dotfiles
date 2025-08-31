#!/bin/bash

# This assumes network manager is already insntalled as part of arch-install
# sudo pacman -S networkmanager
# sudo systemctl enable --now NetworkManager.service
#
# Make sure the basics are installed to continue running this script
sudo pacman -S --needed kitty git neovim vim stow zip unzip base-devel multilib-devel --noconfirm

# Clone dotfiles
cd ~
git clone https://github.com/tannerellen/.dotfiles.git
rm ~/.bashrc

# Create folders for stow so it doesn't link parent folders
sudo mkdir -p /usr/share/applications/
sudo mkdir -p /etc/sddm.conf.d/

mkdir -p ~/.local/share/applications
mkdir -p ~/.local/share/icons

mkdir -p ~/.local/share/flatpak
mkdir -p ~/.var/app

# Individual flatpak app configs (so we don't link the folder and just the files)
mkdir -p ~/.var/app/org.qbittorrent.qBittorrent/config/qBittorrent

cd ~/.dotfiles/
stow wallpapers
cd ~/.dotfiles/shared/config
stow --target=$HOME *
cd ~/.dotfiles/arch/config
stow --target=$HOME *
cd ~/.dotfiles/arch/system
sudo stow --target=/ *

# Install theme files
# Vesktop (Discord)
mkdir -p ~/.var/app/dev.vencord.Vesktop/config/vesktop/themes
cp ~/.dotfiles/shared/themes/discord/gruvbox.css ~/.var/app/dev.vencord.Vesktop/config/vesktop/themes

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
sudo systemctl enable sshd.service

# Add user to input group so keyboard status works in waybar
sudo usermod -aG input $(whoami)
# Add user to uucp group to interact with usb serial devices (arduino)
sudo usermod -aG uucp $(whoami)
# Add user to docker group so docker doesn't require sudo
sudo groupadd docker
sudo usermod -aG docker $(whoami)

# Add user to the i2c group to control i2c devices # May not be necessary
# sudo usermod -aG i2c $(whoami)

# Select fastest mirror # Don't auto install for now
# paru -S rate-mirrors-bin
# cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak
# rate-mirrors --allow-root --protocol https arch | grep -v '^#' | sudo tee /etc/pacman.d/mirrorlist

# Optional firmware packages (used for many things but will load microcode)
sudo pacman -S mkinitcpio-firmware --noconfirm

# Processor microcode (processor updates and patches)
sudo pacman -S amd-ucode --noconfirm # for AMD processors
# sudo pacman -S intel-ucode --noconfirm # for Intel processors

# Install additional kernels
# How to configure: https://linuxiac.com/arch-linux-switching-between-multiple-kernels/
sudo pacman -S linux-lts linux-lts-headers --noconfirm

# Wifi
sudo pacman -S wireless-regdb
# Set regulatory domain by editing: /etc/conf.d/wireless-regdom Then uncomment #WIRELESS_REGDOM="US"
sudo sed -i 's/#WIRELESS_REGDOM="US"/WIRELESS_REGDOM="US"/' /etc/conf.d/wireless-regdom

# Important utilities
sudo pacman -S reflector man-db starship dosfstools mtools brightnessctl fzf ripgrep jq fastfetch bottom btop htop nvtop iftop wavemon --noconfirm

# Hyprland packages and plugins
sudo pacman -S hyprland xdg-desktop-portal-hyprland hyprlock hyprpaper hypridle hyprpicker --noconfirm

# Additional portals (gtk used as filepicker as hyprland portal doesn't support file pickers)
sudo pacman -S xdg-desktop-portal-gtk --noconfirm

# Terminal file chooser portal
paru -S xdg-desktop-portal-termfilechooser-hunkyburrito-git

# Authentication agent
# https://wiki.archlinux.org/title/Polkit
sudo pacman -S polkit-gnome --noconfirm

# QT
sudo pacman -S qt5-wayland qt6-wayland --noconfirm

# GTK2 for some apps (like dadroit)
sudo pacman -S gtk2 --noconfirm

# Fonts
paru -S terminus-font ttf-ubuntu-font-family ttf-firacode-nerd ttf-ubuntu-mono-nerd ttf-jetbrains-mono-nerd noto-fonts-emoji noto-fonts-cjk noto-fonts-extra noto-fonts nerd-fonts-noto-sans-mono --noconfirm

# Theme
# https://github.com/lassekongo83/adw-gtk3
sudo pacman -S adw-gtk-theme breeze breeze5 breeze-gtk breeze-icons gnome-themes-extra nwg-look qt5ct qt6ct --noconfirm

# Use libadwaita for gtk4 without needing adwaita theme
paru -S libadwaita-without-adwaita-git --noconfirm

# Xsettings for xwayland apps used to handle dpi settings for proper sizing
sudo pacman -S xorg-xrdb --noconfirm

# Screen capture
sudo pacman -S grim slurp satty --noconfirm

# Notification daemon
sudo pacman -S swaync --noconfirm

# Display manager
sudo pacman -S sddm sddm-kcm --needed qt6-5compat qt6-declarative qt6-svg qt6-multimedia-ffmpeg qt6-virtualkeyboard --noconfirm

sudo git clone -b master --depth 1 https://github.com/keyitdev/sddm-astronaut-theme.git /usr/share/sddm/themes/sddm-astronaut-theme
sudo cp -r /usr/share/sddm/themes/sddm-astronaut-theme/Fonts/* /usr/share/fonts/
sudo sed -i 's/Current=/Current=sddm-astronaut-theme/' /usr/lib/sddm/sddm.conf.d/default.conf
sudo systemctl enable sddm.service

# Audio
# pipewire and wireplumber Should be installed from arch-install
# lsp-plugins and calf are easyeffects dependencies
sudo pacman -S pavucontrol easyeffects pamixer wob lsp-plugins calf --needed pipewire wireplumber --noconfirm

# Hide desktop entries for lsp-plugins so it doesn't flood app launchers
find /usr -name "*lsp_plug*desktop" 2>/dev/null | xargs -I {} sudo sh -c 'printf "\nNoDisplay=true\n" >> "{}"'

paru -S cava --noconfirm


# Create listener file for wob volume indicator
mkfifo /tmp/wobpipe

# Video and GPU
# https://wiki.archlinux.org/title/Vulkan
# https://wiki.archlinux.org/title/OpenGL
# https://wiki.archlinux.org/title/AMDGPU
# libva-utils has utilities to work with vapi for example vainfo to check status of vapi
sudo pacman -S wlr-randr vulkan-icd-loader lib32-vulkan-icd-loader vulkan-radeon lib32-vulkan-radeon mesa lib32-mesa libva-utils --noconfirm

# libva-mesa-driver --noconfirm # This should be installed with the mesa package

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

# Waybar
paru -S waybar-cava --noconfirm

# Application launcher
sudo pacman -S rofi-wayland rofi-emoji fuzzel --noconfirm

# File manager
sudo pacman -S thunar thunar-volman gvfs --noconfirm

# wlogout
paru -S wlogout --noconfirm

# Clipboard
sudo pacman -S wl-clipboard wl-clip-persist --noconfirm
paru -S clipse --noconfirm

# Nodejs with nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash
source ~/.bashrc
nvm install v20.17.0

# Bun
paru -S bun-bin --noconfirm

# Image viewers
sudo pacman -S imv --noconfirm

# Video / screencasts
paru -S wf-recorder wl-screenrec --noconfirm

# RGB control
sudo pacman -S openrgb --noconfirm

# Keyring / Passwords
# https://wiki.archlinux.org/title/GNOME/Keyring
sudo pacman -S gnome-keyring libsecret seahorse --noconfirm
systemctl --user enable --now gcr-ssh-agent.socket

# Fuse required for app images and sshfs for mounting ssh file systems
sudo pacman -S fuse2 sshfs --noconfirm

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
sudo pacman -S smbclient --noconfirm

# Sensors and fans
sudo pacman -S lm_sensors --noconfirm
# sudo sensors-detect --auto

# i2c / rgb
sudo pacman -S i2c-tools --noconfirm
# enable i2c bus for rgb
# echo 'i2c-dev' | sudo tee -a /etc/modules-load.d/i2c-dev.conf

# Software to use loopback video device to share screen as second camera
# https://www.math.cmu.edu/~gautam/sj/blog/20220326-zoom-wayland.html
# sudo pacman -S v4l2loopback-utils v4l2loopback-dkms linux-headers --noconfirm
# Launch obs and click "Start Virtual Camera"

##### User apps #####
sudo pacman -S firefox vivaldi lazygit yazi perl-image-exiftool imagemagick gtk-vnc p7zip gamescope gamemode syncthing gparted gnome-disk-utility steam arduino-cli weechat nmap rpi-imager gnome-multi-writer tmux gnome-boxes mpv mpv-mpris cameractrls amdgpu_top docker docker-compose --noconfirm
paru -S google-chrome 1password-beta 1password-cli kalc-bin wayvnc parsec wlvncc-git uxplay sunshine firefox-pwa esptool3.2 quickemu yt-dlp --noconfirm

# esptool is used to flash esp32 devices to factory settings and more: https://randomnerdtutorials.com/esp32-erase-flash-memory/

# yazi support apps
sudo pacman -S --needed ffmpegthumbnailer zoxide p7zip jq ripgrep fd fzf imagemagick ueberzugpp chafa --noconfirm

# Tmux plugin manager
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Update man page caches
sudo mandb

##### Cleanup and after install items #####
systemctl --user enable --now syncthing.service

# Enable trim (don't run this if your primary drive doesn't support it)
# https://wiki.archlinux.org/title/Solid_state_drive
# Run trim command manually with: sudo fstrim -av
sudo systemctl enable --now fstrim.timer

# If installing obs with paru then make sure to install wlrobs since we are using the flatpak it's not necessary

# Install flatpak
sudo pacman -S flatpak --noconfirm
# Expose breeze gtk theme
flatpak override --user --filesystem=xdg-config/gtk-3.0:ro
flatpak override --user --filesystem=xdg-config/gtk-4.0:ro

# Install flatpak stuff
flatpak remote-add -y --noninteractive --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install -y --noninteractive --user flatseal

# Install app image manager
flatpak install -y --noninteractive --user it.mijorus.gearlever

flatpak install -y --noninteractive --user org.mozilla.Thunderbird
flatpak install -y --noninteractive --user com.obsproject.Studio
flatpak install -y --noninteractive --user com.slack.Slack
flatpak install -y --noninteractive --user us.zoom.Zoom
flatpak install -y --noninteractive --user dev.vencord.Vesktop
flatpak install -y --noninteractive --user com.prusa3d.PrusaSlicer
flatpak install -y --noninteractive --user com.ultimaker.cura
flatpak install -y --noninteractive --user org.localsend.localsend_app
flatpak install -y --noninteractive --user org.remmina.Remmina
flatpak install -y --noninteractive --user org.videolan.VLC
# flatpak install -y --noninteractive --user io.mpv.Mpv
flatpak install -y --noninteractive --user io.github.celluloid_player.Celluloid
flatpak install -y --noninteractive --user org.kde.digikam
flatpak install -y --noninteractive --user flathub org.gnome.gedit
flatpak install -y --noninteractive --user com.transmissionbt.Transmission
# qBittorrent gruvebox theme from: https://github.com/MahdiMirzadeh/qbittorrent
flatpak install -y --noninteractive --user org.qbittorrent.qBittorrent
flatpak install -y --noninteractive --user org.libreoffice.LibreOffice
flatpak install -y --noninteractive --user org.gnome.SimpleScan
flatpak install -y --noninteractive --user org.shotcut.Shotcut
flatpak install -y --noninteractive --user org.gnome.gitlab.YaLTeR.VideoTrimmer
flatpak install -y --noninteractive --user com.rustdesk.RustDesk
flatpak install -y --noninteractive --user org.audacityteam.Audacity

# Installs as "Image Viewer"
flatpak install -y --noninteractive --user org.gnome.Loupe

# Extract text from images
flatpak install -y --noninteractive --user com.github.tenderowl.frog

# Send and receive iMessage messages
flatpak install -y --noninteractive --user app.bluebubbles.BlueBubbles

# Pipewire volume control
flatpak install -y --noninteractive --user com.saivert.pwvucontrol

# Upscaler
flatpak install -y --noninteractive --user flathub io.gitlab.theevilskeleton.Upscaler
# Gimp Beta
flatpak install -y --noninteractive --user https://flathub.org/beta-repo/appstream/org.gimp.GIMP.flatpakref
# Bottles
flatpak install -y --noninteractive --user com.usebottles.bottles
# Heroic game launcher
flatpak install -y --noninteractive --user com.heroicgameslauncher.hgl
# ProtonPlus for other proton versions like protonGE
flatpak install -y --noninteractive --user com.vysp3r.ProtonPlus
# Emoji picker
flatpak install -y --noninteractive --user com.tomjwatson.Emote
# ISO image writer
flatpak install -y --noninteractive --user io.gitlab.adhami3310.Impression

## Update flatpak so it cleans up and installs any themes
flatpak update -y --noninteractive

# Install hyprhelpr
curl -L -o hyprhelpr.zip https://github.com/tannerellen/hyprhelpr/releases/download/v0.2.0/hyprhelpr.zip
unzip hyprhelpr.zip
sudo mv hyprhelpr /usr/local/bin/
rm hyprhelpr.zip

# Install FileManager1.common (used to show terminal file picker instead of gui)
# https://github.com/boydaihungst/org.freedesktop.FileManager1.common
sudo pacman -S --needed meson ninja gcc pkgconf dbus systemd glib2
cd ~
git clone https://github.com/boydaihungst/org.freedesktop.FileManager1.common
cd org.freedesktop.FileManager1.common
meson setup build --reconfigure
sudo ninja -C build install
rm -rf org.freedesktop.FileManager1.common

# Ryujinx AppImage
# https://git.ryujinx.app/kenji-nx/ryujinx
# https://github.com/ryujinx-mirror/ryujinx
# cd ~
# curl -L -o Ryujinx https://github.com/ryujinx-mirror/ryujinx/releases/download/r.49574a9/ryujinx-r.49574a9-x64.AppImage
# chomd +x Ryujinx
# sudo mv Ryujinx /usr/local/bin
# curl -L -o Ryujinx.svg https://raw.githubusercontent.com/ryujinx-mirror/ryujinx/refs/heads/mirror/master/distribution/misc/Logo.svg
# sudo mv Ryujinx.svg /usr/share/pixmaps

# Ryujinx app
# cd ~
# curl -L -o ryujinx.tar.gz https://github.com/GreemDev/Ryujinx/releases/download/1.2.69/ryujinx-1.2.69-linux_x64.tar.gz
# tar -xzf ryujinx.tar.g
# rm ryujinx.tar.gz
# mkdir -p .local/bin
# mv publish .local/bin/ryujinx
# sed -i 's/exec $COMMAND/exec env AVALONIA_SCREEN_SCALE_FACTORS='DP-1=1.8' $COMMAND/' ~/.local/bin/ryujinx/Ryujinx.sh

# Ryujinx app image
# Download latest version from:
#https://github.com/Ryubing/Stable-Releases/releases/
# Then chmod +x the file and move to /usr/local/bin/ryujinx

# Add ryujinx icon
cd ~
curl -L -o Ryujinx.svg https://raw.githubusercontent.com/ryujinx-mirror/ryujinx/refs/heads/mirror/master/distribution/misc/Logo.svg
mkdir -p .local/share/pixmaps
sudo mv Ryujinx.svg .local/share/pixmaps

# Edit Prusa Slicer desktop file so it opens at scale factor of 1 (No longer needed becuase it looks like this is now being set by default on install)
# sudo sed -i 's/Exec=/Exec=env GDK_SCALE=1 /' /usr/share/applications/PrusaSlicer.desktop
# sudo sed -i 's/Exec=/Exec=env GDK_SCALE=1 /' ~/.local/share/flatpak/exports/share/applications/com.prusa3d.PrusaSlicer.desktop

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

# Play youtube on mpv
# https://github.com/Baldomo/open-in-mpv
cd ~
git clone git@github.com:Baldomo/open-in-mpv.git
cd open-in-mpv
sudo make install
make install-protocol
cd ..
sudo rm -rf open-in-mpv
# installs desktop file in ~/.local/share/applications and app in /usr/bin
#
mkdir -p ~/.local/bin
curl -L https://github.com/ryze312/ff2mpv-rust/releases/download/1.1.7/ff2mpv-rust-x86_64-unknown-linux-gnu -o ~/.local/bin/ff2mpv-rust
chmod +x ~/.local/bin/ff2mpv-rust
~/.local/bin/ff2mpv-rust manifest > ~/.mozilla/native-messaging-hosts/ff2Mpv.json
# Add ff2mpv-rust config
echo "{ \"player_command\": \"$HOME/.config/hypr/scripts/mpv-yt.sh\" }" > ~/.config/ff2mpv-rust.json

# Firefox web extension stuff
# https://github.com/mozilla/web-ext
npm install --global web-ext
# Using web-ext
# https://extensionworkshop.com/documentation/develop/getting-started-with-web-ext/
# web-ext sign --channel=unlisted --api-key=$AMO_JWT_ISSUER --api-secret=$AMO_JWT_SECRET

# Optional config stuff
#
# Set up printer with cups:
# Go to web address https://localhost:631 and click administration to add new printers
#
# Firefox custimzation
# SimpleFox: https://github.com/migueravila/SimpleFox
# GruvBox Material: https://addons.mozilla.org/en-US/firefox/addon/gruvbox-material-dark-official/
#
#
# Enable wake on lan (probably not needed as the default is enabled)
# nmcli con show # To get device name like "Wired connection 1"
# nmcli c show "wired1" | grep 802-3-ethernet.wake-on-lan # To get the status
# To enable:
# nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan magic
# To disable:
# nmcli c modify "Wired connection 1" 802-3-ethernet.wake-on-lan ignore
#
# Get mac address:
# ip link
