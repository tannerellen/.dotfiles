-- import telescope plugin safely
local telescope_setup, telescope = pcall(require, "telescope")
if not telescope_setup then
	return
end

-- import telescope actions safely
local actions_setup, actions = pcall(require, "telescope.actions")
if not actions_setup then
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
			initial_mode = "normal",
			mappings = {
				n = {
					-- map actions.which_key to <C-h> (default: <C-/>)
					-- actions.which_key shows the mappings for your picker,
					-- e.g. git_{create, delete, ...}_branch for the git_branches picker
					["d"] = actions.delete_buffer,
				},
			},
		},
	},
})
