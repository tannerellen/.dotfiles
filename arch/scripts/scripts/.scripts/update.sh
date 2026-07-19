#!/usr/bin/env bash
## A script to update all packages on the system
set -e  # stop on first error

# Load nvm so npm/node are available even in non-interactive shells
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Notify on any failure, with the offending command and line number
on_error() {
    local exit_code=$?
    local line_no=$1
    notify-send -u critical "System Update Failed" "Command failed at line $line_no (exit code $exit_code): $BASH_COMMAND"
    exit "$exit_code"
}
trap 'on_error $LINENO' ERR

# Track when our updates start
START_TIME=$(date '+%Y-%m-%dT%H:%M:%S')

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

# Show notification that updates are complete
notify-send "System Update" "Update is complete"

############################################################
# Reboot logic
############################################################
echo ""
echo "Checking if a reboot is recommended..."
echo ""
REBOOT_PATTERN='^(linux|linux-lts|linux-zen|linux-hardened|.*-git|mesa|nvidia|systemd|hyprland)'

# Pull just the package names from upgrade lines logged since the script started
RECENT_UPGRADES=$(awk -v since="$START_TIME" '$0 > "["since' /var/log/pacman.log \
    | awk '/upgraded/ {print $4}')

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
