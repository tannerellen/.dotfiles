-- import comment plugin safely
local status, comment = pcall(require, "Comment")
if not status then
	print("nvim-comment did not load")
	return
end

-- enable comment
comment.setup({
	-- Properly call comment string so it works with context comments like svelte files
	pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
})
