-- see https://wiki.hyprland.org/Configuring/XWayland/

hl.config({
	xwayland = {
		force_zero_scaling = true, -- Prevents xwayland from scaling if set to true
		use_nearest_neighbor = false, -- Makes the text blurry but looks a little better
	},
	render = {
		direct_scanout = 2,
	},
	ecosystem = {
		no_update_news = true,
		no_donation_nag = true,
	},
	-- https://wiki.hyprland.org/Configuring/Variables/#misc
	misc = {
		force_default_wallpaper = -1, -- Set to 0 or 1 to disable the anime mascot wallpapers
		disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
		disable_splash_rendering = true, -- Disables the random text sayings
		focus_on_activate = true, -- Switches to app in workspace that needs focust automatically (clicked links go to browser)
		vrr = 1, -- (variable refresh rate) 0 off, 1 on, 2 fullscreen
		anr_missed_pings = 3, -- How many missed pings before showing app not responding dialog
		initial_workspace_tracking = 0, -- Turn off as it's buggy. Default is 1 (one shot)
	},
})
