-- import gitsigns plugin safely
local status, gitsigns = pcall(require, "gitsigns")
if not status then
	print("gitsigns did not load")
	return
end

-- configure/enable gitsigns
gitsigns.setup()
