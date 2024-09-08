#!/bin/bash

monitor=`hyprctl monitors | grep Monitor | awk '{print $2}'`

~/.config/hypr/scripts/wallpapers.sh

hyprctl hyprpaper unload all
hyprctl hyprpaper preload "~/.cache/wallpapers/wallpaper.jpg"
hyprctl hyprpaper wallpaper "$monitor,~/.cache/wallpapers/wallpaper.jpg"
