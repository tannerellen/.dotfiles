#!/usr/bin/env bash

## A script to update all packages on the system

set -e  # stop on first error

# Update system packages
echo ""
echo "Updating system..."
echo ""
paru -Syu

# Update flatpak
echo ""
echo "Updating flatpak apps..."
echo ""
flatpak update

# Update rust apps installed with cargo
echo ""
echo "Updating cargo apps..."
echo ""

LOCKED_APPS=("concord") # Space separated list of apps that were installed with --locked

# Update all apps
cargo install-update -a

# Re-install locked apps to restore correct dependency versions
for app in "${LOCKED_APPS[@]}"; do
    if cargo install-update --list | grep -q "^$app"; then
        echo "Re-installing $app with --locked..."
        cargo install "$app" --locked
    else
        echo "Skipping $app (not installed)"
    fi
done

# Update python apps installed with uv
echo ""
echo "Updating UV apps..."
echo ""
uv tool upgrade --all

# Update global npm packages
echo ""
echo "Updating npm packages..."
echo ""
npm update -g

# Update yazi file manager plugins
echo ""
echo "Updating Yazi plugins..."
echo ""
ya pkg upgrade
