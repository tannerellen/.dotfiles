--############
--## INPUT ###
--############

-- https://wiki.hyprland.org/Configuring/Variables/#input

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

hl.device({
	name = "epic-mouse-v1",
	sensitivity = -0.5,
})

hl.config({
	input = {
		kb_layout = "us",
		kb_variant = "",
		kb_model = "",
		kb_options = "",
		kb_rules = "",
		follow_mouse = 1,
		follow_mouse_threshold = 5.0,
		sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
		scroll_factor = 1.3,
		touchpad = {
			disable_while_typing = true,
			natural_scroll = true,
		},
	},
	-- https://wiki.hypr.land/Configuring/Gestures/
	-- Example per-device config
	-- See https://wiki.hyprland.org/Configuring/Keywords/#per-device-input-configs for more
})
