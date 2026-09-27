-- Fix slack issue when huddle is opened and the rendering is messed up
hl.on("window.open", function(win)
	-- win.initialClass / win.initialTitle are set at window creation time
	local class = win.initialClass or win.class or ""
	local title = win.initialTitle or ""

	local is_slack = class == "com.slack.Slack"
	local is_main_window = title == "Slack" or title:find("%(Channel%)") ~= nil
	local is_floating = win.floating == true

	if is_slack and not is_main_window and is_floating then
		-- Give the window a tick to actually map before we resize it.
		-- hyprlua exposes a timer; adjust if your version's API differs.
		hl.timer(function()
			-- target the specific window rather than "active", in case
			-- focus hasn't switched to it yet
			-- Resize 1 pixel bigger
			hl.dispatch(hl.dsp.window.resize({ window = win, x = 1, y = 1, relative = true }))
			hl.timer(function()
				-- Resize 1 pixel smaller to revert change after slight delay
				hl.dispatch(hl.dsp.window.resize({ window = win, x = -1, y = -1, relative = true }))
			end, { timeout = 200, type = "oneshot" })
		end, { timeout = 200, type = "oneshot" })
	end
end)
