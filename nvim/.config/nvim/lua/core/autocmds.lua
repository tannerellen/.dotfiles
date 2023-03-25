-- vim.cmd([[
vim.api.nvim_create_augroup("TerminalSettings", {})

-- Disable line numbers when opening terminal window
vim.api.nvim_create_autocmd("TermOpen", {
	pattern = "term://*",
	command = "setlocal nonumber norelativenumber | setfiletype terminal",
	group = "TerminalSettings",
})

vim.api.nvim_create_autocmd("TermClose", {
	pattern = "term://*",
	callback = function()
		vim.api.nvim_input("<CR>")
	end,
	group = "TerminalSettings",
})

--
--	the following 2 lines can be enabled to automatically enter inert mode when openeing a terminal
--	autocmd BufWinEnter,WinEnter term://* startinsert
--	autocmd BufLeave term://* stopinsert
--
