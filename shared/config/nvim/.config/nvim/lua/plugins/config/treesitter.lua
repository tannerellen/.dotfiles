local status, treesitter = pcall(require, "tree-sitter-manager")
if not status then
	print("nvim-treesitter did not load")
	return
end

-- configure treesitter parsers
treesitter.setup({
	-- enable indentation
	indent = { enable = true },
	-- enable autotagging (w/ nvim-ts-autotag plugin)
	autotag = { enable = true },
	-- ensure these language parsers are installed
	ensure_installed = {
		"json",
		"javascript",
		"typescript",
		"tsx",
		"yaml",
		"html",
		"css",
		"markdown",
		"markdown_inline",
		"svelte",
		"bash",
		"lua",
		"dockerfile",
		"gitignore",
	},
	-- auto install above language parsers
	auto_install = true,
})

-- disable query injections for languages that don't use it much
-- improves performance on larger files
-- https://www.reddit.com/r/neovim/comments/1144spy/will_treesitter_ever_be_stable_on_big_files/
vim.treesitter.query.set("javascript", "injections", "")
vim.treesitter.query.set("typescript", "injections", "")
vim.treesitter.query.set("tsx", "injections", "")
vim.treesitter.query.set("lua", "injections", "")

local autotagStatus, autotag = pcall(require, "nvim-ts-autotag")
if not autotagStatus then
	print("nvim-ts-autotag did not load")
	return
end

autotag.setup({
	opts = {
		enable_close_on_slash = true, -- Auto close on trailing </
	},
})

-- Hook ts_context_commentstring into native Neovim commenting (0.10+)
require("ts_context_commentstring").setup({ enable_autocmd = false })
local get_option = vim.filetype.get_option
vim.filetype.get_option = function(filetype, option)
	return option == "commentstring" and require("ts_context_commentstring.internal").calculate_commentstring()
		or get_option(filetype, option)
end
