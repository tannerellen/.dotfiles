--###############
--## MONITORS ###
--###############

-- See https://wiki.hyprland.org/Configuring/Monitors/

-- Generic default (hotplugged monitor)
hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "2",
})

-- Framework Laptop
hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "auto",
	scale = "2",
	icc = "/home/tannerellen/.config/hypr/color-profiles/BOE0CB4.icc",
})

-- Dell 32"
hl.monitor({
	output = "DP-1",
	mode = "3840x2160@144",
	position = "0x0",
	scale = "1.875000",
})
