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
	-- color palette taken from gruvbox material medium intensity:
	-- https://user-images.githubusercontent.com/58662350/213884019-cbcd5f00-5bef-4a37-9139-0570770330b6.png
	palette_overrides = {
		bright_red = "#ea6962",
		bright_orange = "#e78a4e",
		bright_yellow = "#d8a657",
		bright_green = "#a9b665",
		bright_aqua = "#89b482",
		bright_purple = "#d3869b",
		bright_blue = "#7daea3",
	},
	overrides = {
		TelescopeResultsDiffChange = { fg = "#d8a657", bg = "NONE" },
		TelescopeResultsDiffAdd = { fg = "#a9b665", bg = "NONE" },
		TelescopeResultsDiffDelete = { fg = "#ea6962", bg = "NONE" },
		TelescopeResultsDiffUntracked = { bg = "NONE" },
	},
})

vim.cmd("colorscheme gruvbox") -- run command to set colorscheme name

-- must load after colorscheme
-- remove background for floating borders / window
vim.cmd("hi " .. "FloatBorder" .. " guibg=" .. "NONE")
vim.cmd("hi " .. "NormalFloat" .. " guibg=" .. "NONE")
