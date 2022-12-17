-- set colorscheme to with protected call
-- in case it isn't installed
local status, _ = pcall(vim.cmd, "colorscheme gruvbox-material") -- run command to set colorscheme name
if not status then
	print("Colorscheme not found!") -- print error if colorscheme not installed
	return
end
