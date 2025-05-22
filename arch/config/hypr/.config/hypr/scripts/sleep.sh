#!/bin/bash
pidof hyprlock || hyprlock --immediate & 
sleep 0.5
hyprctl dispatch dpms off &&
sleep 3
systemctl suspend
