-- import nvim-treesitter plugin safely
local status, treesitter = pcall(require, "nvim-treesitter.configs")
if not status then
	return
end

-- configure treesitter
treesitter.setup({
	-- Enable context commentstring plugin (https://github.com/JoosepAlviste/nvim-ts-context-commentstring)
	-- Used for file types with multiple formats in one file like Svelte
	context_commentstring = {
		enable = true,
		enable_autocmd = false, -- Disabled so nvim-comment works properly with this
	},
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
		"svelte",
		"bash",
		"lua",
		"dockerfile",
		"gitignore",
	},
	-- auto install above language parsers
	auto_install = false,
})
