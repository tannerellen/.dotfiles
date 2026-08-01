-- Fix slack issue when huddle is opened and the rendering is messed up
hl.on("window.open", function(win)
	-- win.initialClass / win.initialTitle are set at window creation time
	local class = win.initialClass or win.class or ""
	local title = win.initialTitle or win.title or ""

	local is_slack = class == "com.slack.Slack"
	local is_huddle = title:match("^Huddle:") ~= nil

	if is_slack and is_huddle then
		-- Give the window a tick to actually map before we resize it.
		-- hyprlua exposes a timer; adjust if your version's API differs.
		hl.timer(function()
			-- target the specific window rather than "active", in case
			-- focus hasn't switched to it yet
			-- Resize 1 pixel bigger
			hl.dispatch(resize({ 1, 1, true, win }))
			hl.timer(function()
				-- Resize 1 pixel smaller to revert change after slight delay
				hl.dispatch(resize({ -1, -1, true, win }))
			end, { timeout = 25, type = "oneshot" })
		end, { timeout = 50, type = "oneshot" })
	end
end)
