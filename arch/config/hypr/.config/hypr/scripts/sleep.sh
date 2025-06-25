#!/bin/bash
sleep 0.25 # Very small delay to give screen time to clear before hyprlock appears
pidof hyprlock || hyprlock --immediate & 
hyprctl dispatch dpms off &&
# The following delay will do 2 things...
# 1. It will allow hyprlock time to render so when waking it's already up.
# 2. It will allow the monitor to fully sleep before computer sleeps preventing crash that appears to affect the gpu
sleep 3
systemctl suspend
