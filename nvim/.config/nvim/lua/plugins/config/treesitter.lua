-- import nvim-treesitter plugin safely
local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
	print("nvim-treesitter did not load")
	return
end

-- configure treesitter
treesitter.setup({
	-- enable syntax highlighting
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
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
