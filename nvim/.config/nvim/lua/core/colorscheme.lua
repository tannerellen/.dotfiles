-- color palette taken from gruvbox material medium intensity:
-- https://user-images.githubusercontent.com/58662350/213884019-cbcd5f00-5bef-4a37-9139-0570770330b6.png
local customColors = {
	bright_red = "#ea6962",
	bright_orange = "#e78a4e",
	bright_yellow = "#d8a657",
	bright_green = "#a9b665",
	bright_aqua = "#89b482",
	bright_purple = "#d3869b",
	bright_blue = "#7daea3",
}

local customHighlights = {
	TelescopeResultsDiffChange = { fg = customColors.bright_yellow, bg = "NONE" },
	TelescopeResultsDiffAdd = { fg = customColors.bright_green, bg = "NONE" },
	TelescopeResultsDiffDelete = { fg = customColors.bright_red, bg = "NONE" },
	TelescopeResultsDiffUntracked = { bg = "NONE" },
}

require("gruvbox").setup({
	transparent_mode = true,
	undercurl = true,
	underline = true,
	bold = true,
	italic = {
		strings = true,
		comments = true,
		operators = false,
		folds = true,
	},
	strikethrough = true,
	inverse = true, -- invert background for search, diffs, statuslines and errors
	contrast = "soft", -- can be "hard", "soft" or empty string
	palette_overrides = customColors,
	overrides = customHighlights,
})

vim.cmd("colorscheme gruvbox") -- run command to set colorscheme name

-- must load after colorscheme
-- remove background for floating borders / window
vim.cmd("hi " .. "FloatBorder" .. " guibg=" .. "NONE")
vim.cmd("hi " .. "NormalFloat" .. " guibg=" .. "NONE")
