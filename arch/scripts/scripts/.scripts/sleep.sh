#!/bin/bash

# If running on a laptop suspend then hibernate
if ls /sys/class/power_supply/BAT* 1> /dev/null 2>&1 || ls /proc/acpi/battery/BAT* 1> /dev/null 2>&1; then
	systemctl suspend-then-hibernate
	exit 0;
fi

# If on a desktop let's do regular suspend with fixes
sleep 0.25 # Very small delay to give screen time to clear from wlogout before hyprlock appears
pidof hyprlock || hyprlock --immediate & 
sleep 0.5 # Very small delay to give hyprlock time to render to prevent flash on wake
hyprctl dispatch dpms off &&
# The following delay will do 2 things...
# 1. It will allow hyprlock time to render so when waking it's already up.
# 2. It will allow the monitor to fully sleep before computer sleeps preventing crash that appears to affect the gpu
sleep 3
systemctl suspend
