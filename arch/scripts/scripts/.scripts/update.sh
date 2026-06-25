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

# Get all installed cargo packages (names only)
ALL_APPS=($(cargo install-update --list | awk 'NR>2 && NF {print $1}'))

# Build list of apps to bulk-update = all apps minus locked ones
UPDATE_APPS=()
for app in "${ALL_APPS[@]}"; do
    skip=false
    for locked in "${LOCKED_APPS[@]}"; do
        [[ "$app" == "$locked" ]] && skip=true && break
    done
    $skip || UPDATE_APPS+=("$app")
done

# Update everything except locked apps
if [ ${#UPDATE_APPS[@]} -gt 0 ]; then
    cargo install-update "${UPDATE_APPS[@]}"
fi

# Now handle locked apps separately, re-installing with --locked if an update is available
for app in "${LOCKED_APPS[@]}"; do
    if cargo install-update --list | grep -q "^$app"; then
        echo "Updating $app with --locked..."
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
