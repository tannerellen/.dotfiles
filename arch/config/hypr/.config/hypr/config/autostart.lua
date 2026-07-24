--################
--## AUTOSTART ###
--################
hl.on("hyprland.start", function() end)

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
	hl.exec_cmd("rm -f /tmp/wobpipe && mkfifo /tmp/wobpipe && tail -f /tmp/wobpipe | wob &")
end)

-- Launch user apps
hl.on("hyprland.start", function()
	-- Applies to every window, but only while enabled.
	local bootRule = hl.window_rule({
		name = "boot-suppress-activate",
		match = { class = ".*" },
		["1password"] = true,
		suppress_event = "activate",
	})

	-- Classes we expect to see open during boot. Once every one of these has
	-- opened at least once, we consider startup "settled" and drop the
	-- suppress rule. Keys are lowercase substrings matched against win.class.
	local pending = {
		thunderbird = true,
		kitty = true,
		firefox = true,
		slack = true,
	}

	local bootWatcher
	local function maybeFinishBoot()
		for _, stillWaiting in pairs(pending) do
			if stillWaiting then
				return
			end
		end
		bootRule:set_enabled(false)
		if bootWatcher then
			bootWatcher:remove()
			bootWatcher = nil
		end
	end

	bootWatcher = hl.on("window.open", function(win)
		if not win or not win.class then
			return
		end
		local class = win.class:lower()
		for key, stillWaiting in pairs(pending) do
			if stillWaiting and class:match(key) then
				pending[key] = false
			end
		end
		maybeFinishBoot()
	end)

	-- Fallback: if something never launches (crash, slow flatpak pull, etc.)
	-- don't suppress activate forever.
	hl.timer(function()
		bootRule:set_enabled(false)
		if bootWatcher then
			bootWatcher:remove()
			bootWatcher = nil
		end
	end, { timeout = 15000, type = "oneshot" })

	-- Wait 2s so this runs after other autostart apps have settled
	hl.timer(function()
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
				slackWatcher:remove()
				-- Make sure we end up on workspace 1 since slack can steal focus
				hl.timer(function()
					hl.dispatch(hl.dsp.focus({ workspace = 1 }))
				end, { timeout = 100, type = "oneshot" })
			end
		end)

		hl.exec_cmd("/usr/bin/1password --silent")
		hl.dispatch(hl.dsp.exec_cmd("[workspace 4 silent] flatpak run org.mozilla.thunderbird"))
		hl.exec_cmd("flatpak run com.slack.Slack")
		hl.dispatch(hl.dsp.exec_cmd("[workspace 2 silent] kitty"))
		hl.dispatch(hl.dsp.exec_cmd("[workspace 1 silent] firefox"))
	end, { timeout = 2000, type = "oneshot" })
end)
