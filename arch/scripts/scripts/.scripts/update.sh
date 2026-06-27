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


############################################################
# Reboot logic
############################################################

# Check if a reboot-relevant package was updated
echo ""
echo "Checking if a reboot is recommended..."
echo ""

REBOOT_PATTERN='^(linux|linux-lts|linux-zen|linux-hardened|.*-git|mesa|nvidia|systemd|hyprland)'

if paru -Qu 2>/dev/null | grep -qE "$REBOOT_PATTERN"; then
    : # there are still updates pending somehow, skip (shouldn't happen post -Syu)
fi

# Better: check what was JUST installed in this run, via pacman log timestamp
SINCE=$(date -d '5 minutes ago' '+%Y-%m-%dT%H:%M')
RECENT_UPGRADES=$(awk -v since="$SINCE" '$0 > "["since && /upgraded/' /var/log/pacman.log)

if echo "$RECENT_UPGRADES" | grep -qE "$REBOOT_PATTERN"; then
    echo "A kernel, GPU, or Hyprland-related package was updated."
    read -rp "Reboot now? [y/N] " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
        reboot
    else
        echo "Skipping reboot. Remember to reboot before your session has been running too long with stale binaries."
    fi
else
    echo "No reboot-relevant packages updated. Skipping reboot."
fi
