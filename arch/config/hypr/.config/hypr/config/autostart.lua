--################
--## AUTOSTART ###
--################

hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("xrdb -load ~/.Xresources")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("wl-clip-persist --clipboard regular")
	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("waybar & swaync")
	hl.exec_cmd("wayvnc")
	hl.exec_cmd("easyeffects --hide-window --service-mode")
	hl.exec_cmd("playerctld daemon")
	hl.exec_cmd("~/.config/hypr/scripts/autostart.sh")
end)
