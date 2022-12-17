-- import comment plugin safely
local setup, nvim_comment = pcall(require, "nvim_comment")
if not setup then
	return
end

-- enable comment
nvim_comment.setup()
