#!/bin/bash

sudo pacman -S tlp tlp-rdw
sudo systemctl enable tlp.service
flatpak install --user com.github.d4nj1.tlpui

paru -S kanata --noconfirm
sudo mkdir -p /etc/kanata/
sudo cp ./kanata/kanata.kbd /etc/kanata/

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
systemctl daemon-reload

echo "Enabling kanata.service..."
systemctl enable kanata.service

echo "Starting/Restarting kanata.service..."
systemctl restart kanata.service

echo "-----------------------------------------------------"
echo "Kanata setup script finished!"
echo "Please REBOOT your system for all changes (especially udev rules) to take effect properly."
echo "After rebooting, check status with: systemctl status kanata.service"
echo "-----------------------------------------------------"

exit 0
