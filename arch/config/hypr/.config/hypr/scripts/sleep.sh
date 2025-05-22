#!/bin/bash
pidof hyprlock || hyprlock --immediate & 
sleep 0.5
hyprctl dispatch dpms off resume sleep 3; hyprctl dispatch dpms on
sleep 3
systemctl suspend
