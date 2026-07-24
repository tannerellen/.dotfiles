--################
--## AUTOSTART ###
--################

-- Applies to every window, but only while enabled.
-- Created (and disabled) only on real startup, inside the hyprland.start
-- handler below -- this keeps it from being recreated (and re-enabled) on
-- every config reload.
hl.on("hyprland.start", function()
	local bootRule = hl.window_rule({
		name = "boot-suppress-activate",
		match = { class = ".*" }, -- matches all windows
		suppress_event = "activate",
	})

	-- Disable it 5 seconds after actual startup
	hl.timer(function()
		bootRule:set_enabled(false)
	end, { timeout = 6000, type = "oneshot" })
end)

-- Launch services and daemons
hl.on("hyprland.start", function()
	hl.exec_cmd("dbus-update-activation-environment --systemd --all")
	hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("xrdb -load ~/.Xresources")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("hyprpaper")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("wl-clip-persist --clipboard regular")
	hl.exec_cmd("clipse -listen")
	hl.exec_cmd("waybar")
	hl.exec_cmd("swaync")
	hl.exec_cmd("wayvnc")
	hl.exec_cmd("easyeffects --hide-window --service-mode")
	hl.exec_cmd("playerctld daemon")
	-- Start wob for volume indicator
	hl.exec_cmd("rm -f /tmp/wobpipe && mkfifo /tmp/wobpipe && tail -f /tmp/wobpipe | wob &")
	-- hl.exec_cmd("~/.config/hypr/scripts/autostart.sh")
end)

-- Launch user apps
hl.on("hyprland.start", function()
	-- Wait 2s so this runs after other autostart apps have settled
	hl.timer(function()
		-- Don't start bluetooth manager by default
		-- hl.exec_cmd("blueman-applet")

		hl.exec_cmd("hyprhelpr wallpaper") -- Set a random wallpaper on start

		-- Slack ignores exec_cmd's workspace rule (it launches via a tray
		-- process, so the real window opens on whatever workspace is active).
		-- Launch it plainly, then move the window ourselves once it appears.
		local slackWatcher

		slackWatcher = hl.on("window.open", function(win)
			if not win then
				return
			end
			if win.class and win.class:lower():match("slack") then
				hl.dispatch(hl.dsp.window.move({
					workspace = 3,
					window = "address:" .. win.address,
					follow = false,
				}))
				-- remove the slack window watcher we added and cleanup
				slackWatcher:remove()
				-- Make sure we end up on workspace 1 since slack can steal focus
				hl.timer(function()
					hl.dispatch(hl.dsp.focus({ workspace = 1 }))
				end, { timeout = 100, type = "oneshot" })
			end
		end)

		-- Launch tray or hidden apps
		-- Force running in xwayland as sometimes unlock window opens too small and cut off
		-- hl.exec_cmd("ELECTRON_OZONE_PLATFORM_HINT=x11 /usr/bin/1password --silent")
		hl.exec_cmd("/usr/bin/1password --silent")

		-- Launch workspace apps
		hl.dispatch(hl.dsp.exec_cmd("[workspace 4 silent] flatpak run org.mozilla.thunderbird"))
		hl.exec_cmd("flatpak run com.slack.Slack")
		hl.dispatch(hl.dsp.exec_cmd("[workspace 2 silent] kitty"))
		hl.dispatch(hl.dsp.exec_cmd("[workspace 1 silent] firefox"))
	end, { timeout = 2000, type = "oneshot" })
end)
