--############################
--## ENVIRONMENT VARIABLES ###
--############################

-- See https://wiki.hyprland.org/Configuring/Environment-variables/

-- XDG Desktop Portal
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")

-- GDK
-- TODO: manual review — malformed env on line 13: GDK_BACKEND,wayland,x11,*
hl.env("GDK_SCALE", "2")

-- QT
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
-- env = QT_QPA_PLATFORMTHEME,gtk3
hl.env("QT_QPA_PLATFORMTHEME", "qt5ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")

-- Avalonia
hl.env("AVALONIA_SCREEN_SCALE_FACTORS", "'DP-1=1.8'")

-- Run SDL2 applications on Wayland. Remove or set to x11 if games that provide older versions of SDL
hl.env("SDL_VIDEODRIVER", "wayland")

-- Clutter package already has wayland enabled, this variable will force Clutter applications to try and use the Wayland backend
hl.env("CLUTTER_BACKEND", "wayland")

-- Firefox
hl.env("MOZ_ENABLE_WAYLAND", "1")

-- OZONE - Chrome and Electron apps
hl.env("OZONE_PLATFORM", "wayland")
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")

-- Cursor
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")
hl.env("XCURSOR_THEME", "Adwaita")

-- Gnome Keyring
hl.env("SSH_AUTH_SOCK", "$XDG_RUNTIME_DIR/gcr/ssh")
