--###################
--## KEYBINDINGSS ###
--###################

-- See https://wiki.hyprland.org/Configuring/Keywords/

local mainMod = "SUPER" -- Sets "Windows" key as main modifier
local fileManager = "thunar"
local terminal = "kitty"
local menu = "rofi"
local logout = "wlogout"

hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))

-- Zooming (magnify)
hl.bind(mainMod .. " + CTRL + Z", hl.dsp.exec_cmd("hyprhelpr zoom 0.5"))

hl.bind(mainMod .. " + SHIFT + CTRL + Z", hl.dsp.exec_cmd("hyprhelpr zoom -0.5"))

hl.bind(mainMod .. " + Z", hl.dsp.exec_cmd("bun run hyprhelpr zoom"))

hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("hyprhelpr toggle claude"))

hl.bind(mainMod .. " + SHIFT + A", hl.dsp.exec_cmd("hyprhelpr toggle deepseek"))

hl.bind(mainMod .. " + T", hl.dsp.exec_cmd("hyprhelpr toggle term-notes"))

hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("hyprhelpr toggle term-calc"))

hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("hyprhelpr toggle sound-control"))

-- bind = $mainMod, M, exec, hyprhelpr toggle cider
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("hyprhelpr toggle music"))

hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("hyprhelpr wallpaper"))
-- Not using the below currently but keeping it as a reference in case my preference changes
-- Usinc a bash command and source so this keeps terminal open on exit of yazi and allows
-- further code execution in same bash session
-- bind = $mainMod, E, exec, $terminal -e bash -c "source ~/.scripts/yazi.sh; exec bash"
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(terminal .. " -e yazi"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + CTRL + Q", hl.dsp.exec_cmd(logout))
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + CTRL + ALT + Q", hl.dsp.exit())

hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
-- bind = $mainMod, F, resizeactive, exact 80% 90%
hl.bind(mainMod .. " + F", hl.dsp.window.center())

hl.bind(mainMod .. " + CTRL + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))

-- bind = $mainMod, P, setFloating
-- bind = $mainMod, P, pin

hl.bind(
	mainMod .. " + SHIFT + SPACE",
	hl.dsp.exec_cmd('pgrep -x "' .. menu .. '" > /dev/null && pkill -x "' .. menu .. '" || hyprhelpr menu')
)
hl.bind(mainMod .. " + P", hl.dsp.window.float({ action = "set" }))
hl.bind(mainMod .. " + P", hl.dsp.window.pin())
hl.bind(mainMod .. " + CTRL + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + CTRL + K", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + CTRL + H", hl.dsp.layout("swapsplit"))
hl.bind(mainMod .. " + CTRL + L", hl.dsp.layout("swapsplit"))

hl.bind(
	mainMod .. " + SPACE",
	hl.dsp.exec_cmd('pgrep -x "' .. menu .. '" > /dev/null && pkill -x "' .. menu .. '" || ' .. menu .. " -show drun")
)

-- Toggle control center
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("swaync-client -t -sw"))

hl.bind(mainMod .. " + V", hl.dsp.exec_cmd(terminal .. " --class clipse -e clipse"))
hl.bind(mainMod .. " + Y", hl.dsp.exec_cmd(terminal .. " --class cava -e cava"))

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("~/.scripts/waybar/waybar-reload.sh"))

hl.bind("CTRL + SHIFT + SPACE", hl.dsp.exec_cmd("1password --quick-access"))

-- Audio Switcher
hl.bind(
	"CTRL + ALT + 2",
	hl.dsp.exec_cmd(
		'~/.scripts/audio-output.sh "alsa_output.usb-Apple__Inc._USB-C_to_3.5mm_Headphone_Jack_Adapter_DWH43470N0FJKLTAT-00.analog-stereo"'
	)
)
hl.bind(
	"CTRL + ALT + 1",
	hl.dsp.exec_cmd('~/.scripts/audio-output.sh "alsa_output.usb-Generic_USB_Audio-00.HiFi__Speaker__sink"')
)

-- Smart Plug
hl.bind("CTRL + ALT + 7", hl.dsp.exec_cmd('curl -X POST http://192.168.50.50/control -d "action=toggle&device=0"'))

-- Screenshots
hl.bind("CTRL + ALT + 3", hl.dsp.exec_cmd("~/.scripts/screenshot.sh -m screen"))
hl.bind("CTRL + ALT + SHIFT + 3", hl.dsp.exec_cmd("~/.scripts/screenshot.sh -m window"))
hl.bind("CTRL + ALT + 4", hl.dsp.exec_cmd("~/.scripts/screenshot.sh -m region"))

-- Screencasts
hl.bind("CTRL + ALT + 5", hl.dsp.exec_cmd("hyprhelpr screencast start --savecommand upload"))
hl.bind("CTRL + ALT + SHIFT + 5", hl.dsp.exec_cmd("hyprhelpr screencast stop --savecommand thunar"))
hl.bind("CTRL + ALT + 6", hl.dsp.exec_cmd("hyprhelpr screencast start region --savecommand upload"))
hl.bind("CTRL + ALT + 0", hl.dsp.exec_cmd("hyprhelpr screencast pause"))
hl.bind("CTRL + ALT + SHIFT + 0", hl.dsp.exec_cmd("hyprhelpr screencast stop --savecommand thunar"))

-- SeedCode Timer
hl.bind("CTRL + ALT + 8", hl.dsp.exec_cmd("~/.scripts/work/timelog.sh start"))
hl.bind("CTRL + ALT + 9", hl.dsp.exec_cmd("~/.scripts/work/timelog.sh stop"))

-- Move window focus
hl.bind(mainMod .. " + TAB", hl.dsp.window.cycle_next({ next = true }))
hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.window.cycle_next({ prev = true }))
hl.bind(mainMod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + down", hl.dsp.focus({ direction = "down" }))
hl.bind(mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))

-- Switch workspaces with mainMod + [0-9]
hl.bind("SHIFT + CTRL + ALT + F", hl.dsp.focus({ workspace = 1 }))
hl.bind("SHIFT + CTRL + ALT + D", hl.dsp.focus({ workspace = 2 }))
hl.bind("SHIFT + CTRL + ALT + S", hl.dsp.focus({ workspace = 3 }))
hl.bind("SHIFT + CTRL + ALT + A", hl.dsp.focus({ workspace = 4 }))
hl.bind("SHIFT + CTRL + ALT + G", hl.dsp.focus({ workspace = 5 }))

hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = 1 }))
hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = 2 }))
hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = 3 }))
hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = 4 }))
hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = 5 }))
hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = 6 }))
hl.bind(mainMod .. " + 7", hl.dsp.focus({ workspace = 7 }))
hl.bind(mainMod .. " + 8", hl.dsp.focus({ workspace = 8 }))
hl.bind(mainMod .. " + 9", hl.dsp.focus({ workspace = 9 }))
hl.bind(mainMod .. " + 0", hl.dsp.focus({ workspace = 10 }))

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
hl.bind(mainMod .. " + CTRL + 1", hl.dsp.window.move({ workspace = 1 }))
hl.bind(mainMod .. " + CTRL + 2", hl.dsp.window.move({ workspace = 2 }))
hl.bind(mainMod .. " + CTRL + 3", hl.dsp.window.move({ workspace = 3 }))
hl.bind(mainMod .. " + CTRL + 4", hl.dsp.window.move({ workspace = 4 }))
hl.bind(mainMod .. " + CTRL + 5", hl.dsp.window.move({ workspace = 5 }))
hl.bind(mainMod .. " + CTRL + 6", hl.dsp.window.move({ workspace = 6 }))
hl.bind(mainMod .. " + CTRL + 7", hl.dsp.window.move({ workspace = 7 }))
hl.bind(mainMod .. " + CTRL + 8", hl.dsp.window.move({ workspace = 8 }))
hl.bind(mainMod .. " + CTRL + 9", hl.dsp.window.move({ workspace = 9 }))
hl.bind(mainMod .. " + CTRL + 0", hl.dsp.window.move({ workspace = 10 }))

-- Move active window to next monitor
hl.bind(mainMod .. " + ALT + TAB", hl.dsp.window.move({ monitor = "+1" }))

-- Resize windows
hl.bind(mainMod .. " + SHIFT + COMMA", hl.dsp.window.resize({ x = -50, y = 0, relative = true }))
hl.bind(mainMod .. " + SHIFT + PERIOD", hl.dsp.window.resize({ x = 50, y = 0, relative = true }))

-- Rotate through workspaces
hl.bind(mainMod .. " + CTRL + TAB", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + CTRL + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))

-- Example special workspace (scratchpad)
-- bind = $mainMod, S, togglespecialworkspace, magic
-- bind = $mainMod SHIFT, S, movetoworkspace, special:magic

-- Scroll through existing workspaces with mainMod + scroll
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with mainMod + LMB/RMB and dragging
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag())
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize())

-- Media binds
-- Output
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd(
		"wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 3%+ && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}' > /tmp/wobpipe"
	),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd(
		"wpctl set-volume @DEFAULT_AUDIO_SINK@ 3%- && wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2 * 100)}' > /tmp/wobpipe"
	),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)

-- Input
hl.bind(
	"SHIFT + XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SOURCE@ 2%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SHIFT + XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 2%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"SHIFT + XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)

-- Requires playerctl
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

-- Brightness requires brightnessctl
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -c backlight s 5%-"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -c backlight s +5%"), { locked = true })
