--#############################
--## WINDOWS AND WORKSPACES ###
--#############################

-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

-- Floating windows

-- XWayland floating fixes:
hl.window_rule({
	match = {
		xwayland = 1,
		float = 1,
	},
	no_anim = true,
})

hl.window_rule({
	match = {
		xwayland = 1,
		float = 1,
		initial_class = "^()$",
		initial_title = "^()$",
	},
	no_focus = true,
	rounding = 0,
})

-- Fix some dragging issues with XWayland
hl.window_rule({
	match = {
		class = "^$",
		title = "^$",
		xwayland = 1,
		float = 1,
		fullscreen = 0,
		pin = 0,
	},
	no_focus = true,
})

-- Don't allow idle on fullscreen windows
hl.window_rule({
	match = {
		class = ".*",
	},
	idle_inhibit = "fullscreen",
})

-- Ignore maximize requests from apps. You'll probably like this.
hl.window_rule({
	match = {
		class = ".*",
	},
	suppress_event = "maximize",
})

-- Opacity Settings
hl.window_rule({
	match = {
		initial_class = "^(kitty|com.mitchellh.ghostty|thunar)$",
	},
	opacity = "0.95 override",
})

-- Utility floating windows
hl.window_rule({
	match = {
		initial_class = "^(blueman-manager|clipse|localsend|nmtui|bluetui|audio-settings)$",
	},
	float = true,
	size = { "680", "800" },
	center = true,
})

-- Make auth window open floating
hl.window_rule({
	match = {
		initial_class = "^(org.kde.polkit-kde-authentication-agent-1)$",
	},
	float = true,
})

-- Make file selector floating and centered
hl.window_rule({
	match = {
		initial_class = "^(Xdg-desktop-portal-gtk)$",
	},
	float = true,
	center = true,
})

-- Term File Chooser
hl.window_rule({
	match = {
		initial_title = "termfilechooser",
	},
	float = true,
	size = { "monitor_w / 1.3", "monitor_h / 1.2" },
	center = true,
})

-- Screenshare window
hl.window_rule({
	match = {
		initial_class = "hyprland-share-picker",
	},
	float = true,
})

-- Make Firefox Picture-in-picture floating and pinned
hl.window_rule({
	match = {
		class = "firefox",
		title = "Picture-in-Picture",
	},
	float = true,
	no_max_size = true,
	move = { "monitor_w - window_w - 10", "monitor_h - window_h - 10" },
	keep_aspect_ratio = true,
	pin = true,
})

-- MPV opened from youtube using ff2mpv
hl.window_rule({
	match = {
		initial_class = "^(mpv-yt)$",
	},
	no_initial_focus = true,
	float = true,
	size = { "600", "338" },
	move = { "monitor_w - (window_w - 20)", "monitor_h - (window_h - 20)" },
	pin = true,
})

-- xwayland steam games don't always open full screen. Force them to:
hl.window_rule({
	match = {
		xwayland = 1,
		float = 1,
		initial_class = "^steam_app_\\d+$",
	},
	fullscreen = true,
})

-- 1Password
hl.window_rule({
	match = {
		initial_class = "^(1Password)$",
		initial_title = "^(Quick Access)",
	},
	stay_focused = true,
})

-- Zoom
hl.window_rule({
	match = {
		initial_class = "zoom",
		initial_title = "menu window",
	},
	stay_focused = true,
})

hl.window_rule({
	match = {
		initial_class = "zoom",
		initial_title = "Zoom Workplace",
	},
	no_follow_mouse = true,
})

-- Slack
hl.window_rule({
	match = {
		initial_class = "com.slack.Slack",
		initial_title = "^(Slack - Huddle Preview|Huddle: .*)",
	},
	float = true,
	center = true,
	size = { "monitor_w / 1.5", "monitor_h / 1.2" },
})

-- qBitterrent
hl.window_rule({
	match = {
		initial_class = "^(org\\.qbittorrent\\.qBittorrent)$",
		initial_title = "negative:^qBittorrent v.*",
	},
	float = true,
	size = { "1050", "800" },
	center = true,
})

-- GIMP windowrules
-- Color picker goes bonkers when a file is open the below conflicting rules fixes that if focus_on_activate is enabled globally
hl.window_rule({
	match = {
		initial_class = "^(org.gimp.GIMP)$",
	},
	focus_on_activate = false,
})

--Kdenlive (make sure floating windows aren't too small)
hl.window_rule({
	match = {
		float = 1,
		initial_title = "Kdenlive",
	},
	min_size = { "1024", "800" },
})

-- Cider music player (render unfocused to keep from crashing)
hl.window_rule({
	match = {
		initial_title = "^(Apple Music)$",
	},
	render_unfocused = true,
})

-- Layer rules
hl.layer_rule({
	match = { namespace = "rofi" },
	dim_around = true,
})

hl.layer_rule({
	match = { namespace = "wob" },
	no_anim = true,
})

-- Black out notifications when screen sharing
hl.layer_rule({
	match = { namespace = "notifications" },
	no_screen_share = true,
})
