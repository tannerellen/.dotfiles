-- import comment plugin safely
local status, nvim_comment = pcall(require, "nvim_comment")
if not status then
	return
end

-- enable comment
nvim_comment.setup({
	-- Properly call comment string so it works with context comments like svelte files
	hook = function()
		require("ts_context_commentstring.internal").update_commentstring()
	end,
})
