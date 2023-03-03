-- set colorscheme with protected call in case it isn't installed
local g = vim.g -- for global settings

-- set global colorscheme options
g.gruvbox_material_background = "medium" -- "soft", "medium", "hard"
g.gruvbox_material_foreground = "material" -- "original", "mix", "material"
g.gruvbox_material_transparent_background = 1 -- 0: disabled, 1: transparent, 2: everything transparent
-- g.gruvbox_material_enable_bold = 1 -- enable bold function names if font supports it
-- g.gruvbox_material_enable_italic = 1 -- enable italics if font supports it

local status, _ = pcall(vim.cmd, "colorscheme gruvbox-material") -- run command to set colorscheme name
if not status then
	print("Colorscheme not found!") -- print error if colorscheme not installed
	return
end

-- must load after colorscheme
-- remove background for floating borders / window
vim.cmd("hi " .. "FloatBorder" .. " guibg=" .. "NONE")
vim.cmd("hi " .. "NormalFloat" .. " guibg=" .. "NONE")
