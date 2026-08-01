--################
--## AUTOSTART ###
--################

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
-- Load wallpaper
hl.on("hyprland.start", function()
	hl.timer(function()
		-- Small delay to make sure hyprpaper and waybar is loaded first. Todo: Could make this more robust by polling hyprpaper and waybar first
		-- Slack ignores exec_cmd's workspace rule (it launches via a tray
		-- process, so the real window opens on whatever workspace is active).
		-- Launch it plainly, then move the window ourselves once it appears.
		-- Thunderbird launches via exec_cmd's workspace rule directly to
		-- workspace 4, but we still wait for its window.open event so we
		-- don't jump to workspace 1 before it's actually settled.
		local slackReady, thunderbirdReady = false, false
		local slackWatcher, thunderbirdWatcher

		local function maybeFocusWorkspace1()
			if slackReady and thunderbirdReady then
				-- Make sure we end up on workspace 1 since slack can steal focus
				hl.timer(function()
					hl.dispatch(hl.dsp.focus({ workspace = 1 }))
				end, { timeout = 100, type = "oneshot" })
			end
		end

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
				slackReady = true
				slackWatcher:remove()
				maybeFocusWorkspace1()
			end
		end)

		thunderbirdWatcher = hl.on("window.open", function(win)
			if not win then
				return
			end
			if win.class and win.class:lower():match("thunderbird") then
				thunderbirdReady = true
				thunderbirdWatcher:remove()
				maybeFocusWorkspace1()
			end
		end)

		-- Select wallpaper
		hl.exec_cmd("hyprhelpr wallpaper")
		-- Launch 1password silently
		hl.exec_cmd("/usr/bin/1password --silent")
		-- Launch apps to workspaces. Make sure to update pending array above with changes here
		hl.dispatch(hl.dsp.exec_cmd("[workspace 4 silent] flatpak run org.mozilla.thunderbird"))
		hl.exec_cmd("flatpak run com.slack.Slack")
		hl.dispatch(hl.dsp.exec_cmd("[workspace 2 silent] kitty"))
		hl.dispatch(hl.dsp.exec_cmd("[workspace 1 silent] firefox"))
	end, { timeout = 1500, type = "oneshot" })
end)
-- local function debug_log(msg)
-- 	local f = io.open("/tmp/autostart-debug.log", "a")
-- 	if f then
-- 		f:write(os.date("%H:%M:%S") .. " " .. msg .. "\n")
-- 		f:close()
-- 	end
-- end
