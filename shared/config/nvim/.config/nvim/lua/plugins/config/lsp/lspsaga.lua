-- import lspsaga safely
local status, lspsaga = pcall(require, "lspsaga")
if not status then
	print("lspsaga did not load")
	return
end

-- Setting severity_sort to fix a bug in lspsaga. Once that bug is fixed can remove
-- https://github.com/nvimdev/lspsaga.nvim/issues/1520
vim.diagnostic.config({
	severity_sort = true,
})

lspsaga.setup({
	-- keybinds for navigation in lspsaga window
	move_in_saga = { prev = "<C-k>", next = "<C-j>" },
	-- show symbols in winbar that include the path to file and function
	symbol_in_winbar = {
		enable = false,
	},
	definition = {
		keys = {
			quit = { "q", "<ESC>" },
			edit = "<CR>",
		},
	},
	diagnostic = {
		on_insert = true,
		on_insert_follow = false,
		keys = {
			quit = { "q", "<ESC>" },
		},
	},
	code_action = {
		keys = {
			quit = { "q", "<ESC>" },
		},
	},
	finder = {
		keys = {
			quit = { "q", "<ESC>" },
			-- use enter to open file with finder
			vsplit = { "v", "<CR>" },
		},
	},
	outline = {
		keys = {
			quit = { "q", "<ESC>" },
		},
	},
	beacon = {
		enable = false, -- disable go to definition highlight
		frequency = 7, -- the blink frequency of the beacon if enabled
	},
})
