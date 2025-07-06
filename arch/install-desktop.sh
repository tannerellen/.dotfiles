#!/bin/bash/

# Update boot loading.conf 
echo -e "timeout 1\nconsole-mode keep" | sudo tee /boot/loader/loader.conf > /dev/null

# Stow specific dotfiles
cd ~/.dotfiles/arch/desktop
stow --target=$HOME *

# AMD GPU Overclocking
paru -S lact --noconfirm

sudo systemctl enable --now lactd

# Create the Bluetooth fix script
cat > /usr/local/bin/fix-bluetooth-on-resume.sh << 'EOF'
#!/bin/bash

# Log file location
LOG_FILE="/var/log/bluetooth-resume-fix.log"

# Wait 2 seconds for Bluetooth subsystem to stabilize
sleep 2

# Check if Bluetooth controller exists (adapter might disappear during suspend)
if ! bluetoothctl show &>/dev/null; then
    echo "$(date) ERROR: Bluetooth controller not detected. Is the adapter powered?" >> "$LOG_FILE"
    exit 1
fi

# Check power state
if ! bluetoothctl show | grep -q "Powered: yes"; then
    echo "$(date) Bluetooth was off. Powering on..." >> "$LOG_FILE"
    bluetoothctl power on >> "$LOG_FILE" 2>&1
else
    echo "$(date) Bluetooth was already on." >> "$LOG_FILE"
fi
EOF

# Make executable
chmod +x /usr/local/bin/fix-bluetooth-on-resume.sh

# Create systemd service (now with clearer naming)
cat > /etc/systemd/system/bluetooth-resume-fix.service << 'EOF'
[Unit]
Description=Fix Bluetooth power state after resume from suspend
After=suspend.target

[Service]
Type=simple
ExecStart=/usr/local/bin/fix-bluetooth-on-resume.sh

[Install]
WantedBy=suspend.target
EOF

# Enable service
systemctl enable --now bluetooth-resume-fix.service

# Create log file
touch /var/log/bluetooth-resume-fix.log
chmod 644 /var/log/bluetooth-resume-fix.log

echo "✅ Bluetooth resume fix installed successfully!"
echo "Check logs with: sudo cat /var/log/bluetooth-resume-fix.log"
