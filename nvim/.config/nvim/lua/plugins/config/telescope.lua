-- import telescope plugin safely
local telescope_status, telescope = pcall(require, "telescope")
if not telescope_status then
	print("telescope did not load")
	return
end

-- import telescope actions safely
local actions_status, actions = pcall(require, "telescope.actions")
if not actions_status then
	print("telescope actions did not load")
	return
end

-- configure telescope
telescope.setup({
	-- configure custom mappings
	defaults = {
		file_ignore_patterns = { "node_modules" },
		path_display = { "truncate" }, -- hidden, tail, absolute, smart, shorten, truncate (truncate can = a number like "truncate = 3")
		preview = {
			treesitter = false, -- Disable treesitter in the preview window so large files don't hang
			filesize_limit = 0.1,
			timeout = 250,
		},
	},
	pickers = {
		buffers = {
			-- initial_mode = "normal",
			mappings = {
				n = {
					["d"] = actions.delete_buffer,
				},
			},
		},
	},
})

-- load fzf exension for faster searching
telescope.load_extension("fzf")
