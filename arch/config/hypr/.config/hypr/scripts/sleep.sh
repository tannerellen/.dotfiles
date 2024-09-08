#!/bin/bash
# pidof swaylock || swaylock -f --grace &
pidof hyprlock || hyprlock --immediate & 
sleep 1
hyprctl dispatch dpms off resume sleep 3; hyprctl dispatch dpms on
systemctl suspend -i
