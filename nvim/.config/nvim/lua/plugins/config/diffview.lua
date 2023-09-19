-- import diffview plugin safely
local status, diffview = pcall(require, "diffview")
if not status then
	print("diffview did not load")
	return
end

-- enable diffview
diffview.setup()
