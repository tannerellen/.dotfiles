-- import diffview plugin safely
local status, diffview = pcall(require, "diffvew")
if not status then
	return
end

-- enable diffview
diffview.setup()
