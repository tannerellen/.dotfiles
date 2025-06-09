#!/bin/bash

# Some notes on changes
# If the systemd boot loader is too small you can change the size in
# /boot/loader/loader.conf
# add:
# console-mode 2
# change timeout 2 for slightly faster loading
#
#
# In /usr/lib/sddm/sddm.conf.d/default.conf
# Make sure to set display server to wayland
# Set GreeterEnvironment=QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192

sudo sed -i 's/GreeterEnvironment=/GreeterEnvironment=QT_SCREEN_SCALE_FACTORS=2,QT_FONT_DPI=192/' /usr/lib/sddm/sddm.conf.d/default.conf

sudo setfont term-v32b

git clone https://github.com/AdnanHodzic/auto-cpufreq.git
cd auto-cpufreq && sudo ./auto-cpufreq-installer
sudo auto-cpufreq --intall
cd ~
rm -rf ~/auto-cpufreq
# To remove daemon sudo auto-cpufreq --remove

# sudo pacman -S power-profiles-daemon --noconfirm
# sudo systemctl enable --now power-profiles-daemon.service
#
# powerprofilesctl configure-battery-aware --enable
# powerprofilesctl trickle_charge --enable
# powerprofilesctl amdgpu_panel_power --enable # Reduces color accuracy to save power
# powerprofilesctl amdgpu_dpm --enable # GPU dynamic power management
# powerprofilesctl set power-saver

# powerprofilesctl list
# powerprofilesctl set power-saver

# sudo pacman -S tlp tlp-rdw --noconfirm
# sudo systemctl enable tlp.service
# flatpak install --user com.github.d4nj1.tlpui

sudo pacman -S powertop --noconfirm

paru -S kanata --noconfirm

#========================
# Create Systemd Service Unit
#========================
echo "Creating systemd service file /etc/systemd/system/kanata.service..."
# Use cat with EOF for cleaner multi-line definition
cat << EOF | sudo tee /etc/systemd/system/kanata.service

[Unit]
Description=Kanata Service
Requires=local-fs.target
After=local-fs.target

[Service]
ExecStart=/usr/bin/kanata -c /etc/kanata/kanata.kbd
Restart=no

[Install]
WantedBy=sysinit.target
EOF

#========================
# Reload Systemd, Enable & Start Service
#========================
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload

echo "Enabling kanata.service..."
sudo systemctl enable kanata.service

echo "Starting/Restarting kanata.service..."
sudo systemctl start kanata.service

echo "-----------------------------------------------------"
echo "Kanata setup script finished!"
echo "Please REBOOT your system for all changes (especially udev rules) to take effect properly."
echo "After rebooting, check status with: systemctl status kanata.service"
echo "-----------------------------------------------------"

# EasyEffects profile for batter laptop audio on internal framework speakers
# https://github.com/cab404/framework-dsp
# These profiles are already in the dotfiles so just select one in easyeffects
