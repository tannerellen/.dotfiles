local keymap = vim.keymap -- easy keymap reference

---------------------
-- General Keymaps (Run On Init)
---------------------
local init = function()
	-- set leader key to space
	vim.g.mapleader = " "

	-- use ESC to turn off search highlighting
	keymap.set("n", "<ESC>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlighting" })

	-- delete single character without copying into register
	keymap.set("n", "x", '"_x', { desc = "Delete character without register" })

	-- must have remaps: https://www.youtube.com/watch?v=hSHATqh8svM
	--
	-- yank to end of line
	keymap.set("n", "Y", "y$", { desc = "Yank to end of line" })
	-- don't revert cursor on yank in visual mode
	keymap.set("v", "y", "ygv<ESC>", { desc = "Keep cursor position on yank" })

	-- center when navigating search result
	keymap.set("n", "n", "nzz", { desc = "Center on next" })
	keymap.set("n", "N", "Nzz", { desc = "Center on previous" })

	-- center when joining lines
	keymap.set("n", "J", "mzJ`z", { desc = "Center on line join" })

	-- move selected lines up or down
	keymap.set("v", "J", ":m '>+1<CR>gv=gv", { silent = true, desc = "Move line down" })
	keymap.set("v", "K", ":m '<-2<CR>gv=gv", { silent = true, desc = "Move line up" })

	-- greatest remap ever
	keymap.set("x", "<leader>p", '"_dP', { desc = "Replaces selected without yanking" })

	-- next greatest remap ever
	keymap.set("n", "<leader>Y", '"+Y', { noremap = false, desc = "Yank current line to clipboard" })
	keymap.set("n", "<leader>y", '"+y', { desc = "Yank to clipboard" })
	keymap.set("v", "<leader>y", '"+y', { desc = "Yank selected to clipboard" })

	-- delete without storing in register
	keymap.set("n", "<leader>d", '"_d', { desc = "Delete without register" })
	keymap.set("v", "<leader>d", '"_d', { desc = "Delete selected wihout register" })

	-- close buffer
	keymap.set("n", "<leader>x", "<cmd>bd<CR>", { desc = "X current buffer (close)" })
	keymap.set("n", "<leader>X", "<cmd>bufdo bd<CR>", { desc = "X all buffers (close)" })

	-- tab management
	keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Tab Open (new)" })
	keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Tab X (close)" })
	keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Tab Next" })
	keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Tab Previous" })

	-- tmux and terminal commands
	--
	-- terminal open to lazy git
	keymap.set(
		"n",
		"<leader>gg",
		"<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazygit <CR><CR>",
		{ desc = "Git Go" }
	) -- opens lazygit in a new tmux window
	-- keymap.set("n", "<leader>gg", "<cmd>term lazygit <CR>") -- opens lazygit in a new window

	-- terminal open to current working directory
	keymap.set(
		"n",
		"<leader>tt",
		"<cmd>!tmux new-window -c " .. vim.fn.getcwd() .. "<CR><CR>",
		{ desc = "Tmux Terminal" }
	) -- opens cwd in a new tmux window
end

----------------------
-- Plugin Keymaps
----------------------
local plugins = function()
	-- telescope
	keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<CR>", { desc = "Find Files" }) -- find files within current working directory
	keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<CR>", { desc = "Find String" }) -- find string in current working directory
	keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<CR>", { desc = "Find Cursor" }) -- find string under cursor in current working directory
	keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<CR>", { desc = "Find Buffers" }) -- list open buffers
	keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<CR>", { desc = "Find Help" }) -- list available help tags
	keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>", { desc = "Find Diagnostics" }) -- list buffer diagnostics
	keymap.set("n", "<leader>fm", "<cmd>Telescope marks<CR>", { desc = "Find Marks" }) -- list marks
	keymap.set("n", "<leader>fj", "<cmd>Telescope jumplist<CR>", { desc = "Find Jumplist" }) -- jumplist
	keymap.set("n", "<leader>fk", "<cmd>Telescope keymaps<CR>", { desc = "Find Keymaps" }) -- keymaps

	-- telescope git commands
	keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<CR>", { desc = "Git Commits" }) -- list all git commits
	keymap.set("n", "<leader>gh", "<cmd>Telescope git_bcommits<CR>", { desc = "Git History" }) -- list git commits for current file/buffer
	keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", { desc = "Git Branches" }) -- list git branches
	keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<CR>", { desc = "Git Status" }) -- list current changes per file with diff preview

	-- git signs
	keymap.set("n", "<leader>gl", "<cmd>Gitsigns toggle_current_line_blame<CR>", { desc = "Git Line" }) -- toggles git line blame

	-- file browser
	keymap.set("n", "<leader>e", "<cmd>Oil<CR>", { desc = "Explore (files)" }) -- open file browser in current path

	-- diffview
	vim.keymap.set("n", "<leader>vd", "<cmd>DiffviewOpen<CR>", { desc = "View Diff" }) -- open diffview on current git index
	vim.keymap.set("n", "<leader>vh", "<cmd>DiffviewFileHistory %<CR>", { desc = "View History" }) -- view file history for current file
	-- diffview opens in a new tab so closing diffview can be done with normal tab controls

	-- harpoon
	keymap.set(
		"n",
		"<leader>hh",
		'<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>',
		{ desc = "Harpoon Helper (menu)" }
	) -- open harpoon marks list
	keymap.set(
		"n",
		"<C-H>",
		'<cmd>lua require("harpoon.mark").add_file()<CR>',
		{ desc = "add current buffer to harpoons" }
	)
	keymap.set(
		"n",
		"<C-J>",
		'<cmd>lua require("harpoon.ui").nav_file(1)<CR>',
		{ desc = "goto specific file in mark position 1" }
	)
	keymap.set(
		"n",
		"<C-K>",
		'<cmd>lua require("harpoon.ui").nav_file(2)<CR>',
		{ desc = "goto specific file in mark position 2" }
	)
	keymap.set(
		"n",
		"<C-L>",
		'<cmd>lua require("harpoon.ui").nav_file(3)<CR>',
		{ desc = "goto specific file in mark position 3" }
	)

	-- comment
	keymap.set("n", "<leader>/", ":CommentToggle<CR>", { silent = true })
	keymap.set("v", "<leader>/", ":CommentToggle<CR>", { silent = true })

	-- clipboard copy with osc52
	vim.keymap.set("v", "<leader>c", '<cmd>lua require("osc52").copy_visual()<CR>', { desc = "Copy (to clipboard)" })
end

---------------------
-- Lsp On Attach Keymaps (Run only when LSP is running)
---------------------
local lsp_on_attach = function(bufnr)
	-- keymap options
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- set keymaps
	keymap.set("n", "gf", "<cmd>Lspsaga finder<CR>", opts) -- show definition, references
	keymap.set("n", "gD", "<Cmd>lua vim.lsp.buf.declaration()<CR>", opts) -- got to declaration
	keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", opts) -- go to definition
	keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", opts) -- see definition and make edits in window
	keymap.set("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts) -- go to implementation
	keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", opts) -- see available code actions
	keymap.set("n", "<leader>rn", "<cmd>Lspsaga rename<CR>", opts) -- smart rename
	keymap.set("n", "<leader>sl", "<cmd>Lspsaga show_line_diagnostics<CR>", opts) -- show  diagnostics for line
	keymap.set("n", "<leader>sd", "<cmd>Lspsaga show_cursor_diagnostics<CR>", opts) -- show diagnostics for cursor
	keymap.set("n", "<leader>sb", "<cmd>Lspsaga show_buf_diagnostics<CR>", opts) -- show diagnostics for cursor
	keymap.set("n", "<leader>sp", "<cmd>Lspsaga diagnostic_jump_prev<CR>", opts) -- jump to previous diagnostic in buffer
	keymap.set("n", "<leader>sn", "<cmd>Lspsaga diagnostic_jump_next<CR>", opts) -- jump to next diagnostic in buffer
	keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", opts) -- show documentation for what is under cursor
	keymap.set("n", "<leader>so", "<cmd>Lspsaga outline<CR>", opts) -- see outline on right hand side
end

-- return keymap modules
return {
	init = init,
	plugins = plugins,
	lsp_on_attach = lsp_on_attach,
}
