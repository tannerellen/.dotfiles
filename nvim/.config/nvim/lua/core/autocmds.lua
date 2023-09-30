vim.api.nvim_create_augroup("TerminalSettings", {})

-- Disable line numbers when opening terminal window, set filetype and enter insert mode
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*",
	command = "setlocal nonumber norelativenumber | setfiletype terminal | startinsert",
	group = "TerminalSettings",
})

-- Auto close terminal window when exiting an app and leave insert mode
vim.api.nvim_create_autocmd("TermClose", {
	pattern = "term://*",
	command = "lua vim.api.nvim_input('<CR>')",
	group = "TerminalSettings",
})
