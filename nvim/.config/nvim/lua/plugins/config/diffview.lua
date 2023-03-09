-- import plugin safely
local setup, diffview = pcall(require, "diffew")
if not setup then
	return
end

-- enable comment
diffview.setup({})
