-- import lspsaga safely
local saga_status, saga = pcall(require, "lspsaga")
if not saga_status then
	return
end

saga.setup({
	-- keybinds for navigation in lspsaga window
	move_in_saga = { prev = "<C-k>", next = "<C-j>" },
	-- use enter to open file with finder
	finder_action_keys = {
		open = "<CR>",
	},
	-- use enter to open file with definition preview
	definition_action_keys = {
		edit = "<CR>",
	},
	-- show symbols in winbar that include the path to file and function
	symbol_in_winbar = {
		enable = false,
	},
	diagnostic = {
		on_insert = true,
		on_insert_follow = false,
	},
	beacon = {
		enable = false, -- disable go to definition highlight
		frequency = 7, -- the blink frequency of the beacon if enabled
	},
})
