-- import lualine plugin safely
local status, lualine = pcall(require, "lualine")
if not status then
	print("lualine did not load")
	return
end

-- get lualine nightfly theme
-- local lualine_nightfly = require("lualine.themes.nightfly")

-- new colors for theme
-- local new_colors = {
-- 	blue = "#65D1FF",
-- 	green = "#3EFFDC",
-- 	violet = "#FF61EF",
-- 	yellow = "#FFDA7B",
-- 	black = "#000000",
-- }

-- change nightlfy theme colors
-- lualine_nightfly.normal.a.bg = new_colors.blue
-- lualine_nightfly.insert.a.bg = new_colors.green
-- lualine_nightfly.visual.a.bg = new_colors.violet
-- lualine_nightfly.command = {
-- 	a = {
-- 		gui = "bold",
-- 		bg = new_colors.yellow,
-- 		fg = new_colors.black, -- black
-- 	},
-- }

-- configure lualine with modified theme
lualine.setup({
	options = {
		-- theme = "nightfly",
		-- theme = "gruvbox-material",
		-- theme = "catppuccin",
		theme = "auto",
		component_separators = { left = "", right = "" },
	},
	sections = {
		lualine_a = {
			{
				"branch",
			},
		},
		lualine_b = {
			{
				"filename",
				path = 1,
				-- 0: Just the filename
				-- 1: Relative path
				-- 2: Absolute path
				-- 3: Absolute path, with tilde as the home directory
			},
			{
				"filetype",
				icon_only = true, -- Display only an icon for filetype
			},
		},
		lualine_c = { "diff", "diagnostics" },
		lualine_x = { "encoding" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})
