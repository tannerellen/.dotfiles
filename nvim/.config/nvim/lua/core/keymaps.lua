local keymap = vim.keymap -- easy keymap reference

---------------------
-- General Keymaps (Run On Init)
---------------------
local init = function()
	-- set leader key to space
	vim.g.mapleader = " "

	-- use ESC to turn off search highlighting
	keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

	-- delete single character without copying into register
	keymap.set("n", "x", '"_x')

	-- close buffer
	keymap.set("n", "<leader>x", ":bd<CR>", { silent = true }) -- (X = close)

	-- tab management
	keymap.set("n", "<leader>to", ":tabnew<CR>", { silent = true }) -- (Tab Open) open new tab
	keymap.set("n", "<leader>tx", ":tabclose<CR>", { silent = true }) -- (Tab X) close current tab
	keymap.set("n", "<leader>tn", ":tabn<CR>", { silent = true }) --  (Tab Next) go to next tab
	keymap.set("n", "<leader>tp", ":tabp<CR>", { silent = true }) --  (Tab Previous) go to previous tab

	-- terminal open to lazy git
	keymap.set(
		"n",
		"<leader>gg",
		":!tmux new-window -c " .. vim.fn.getcwd() .. " -- lazygit <CR><CR>",
		{ silent = true }
	) -- (Git Go) opens lazygit in a new tmux window
	-- keymap.set("n", "<leader>gg", ":term lazygit <CR>", { silent = true }) -- opens lazygit in a new window

	-- terminal open to current working directory
	keymap.set("n", "<leader>tt", ":!tmux new-window -c " .. vim.fn.getcwd() .. "<CR><CR>", { silent = true }) -- (Tmux Terminal) opens cwd in a new tmux window

	-- must have remaps: https://www.youtube.com/watch?v=hSHATqh8svM
	--
	-- yank to end of line
	keymap.set("n", "Y", "y$")
	-- don't revert cursor on yank in visual mode
	keymap.set("v", "y", "ygv<ESC>")

	-- center when navigating search result
	keymap.set("n", "n", "nzz")
	keymap.set("n", "N", "Nzz")

	-- center when joining lines
	keymap.set("n", "J", "mzJ`z")

	-- move selected lines up or down
	keymap.set("v", "J", ":m '>+1<CR>gv=gv")
	keymap.set("v", "K", ":m '<-2<CR>gv=gv")

	-- greatest remap ever
	keymap.set("x", "<leader>p", '"_dP')

	-- next greatest remap ever
	keymap.set("n", "<leader>Y", '"+Y', { noremap = false })
	keymap.set("n", "<leader>y", '"+y')
	keymap.set("v", "<leader>y", '"+y')

	-- delete without storing in register
	keymap.set("n", "<leader>d", '"_d')
	keymap.set("v", "<leader>d", '"_d')
end

----------------------
-- Plugin Keymaps
----------------------
local plugins = function()
	-- telescope
	keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- (Find Files) find files within current working directory, respects .gitignore
	keymap.set("n", "<leader>fs", "<cmd>Telescope live_grep<cr>") -- (Find String) find string in current working directory as you type
	keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- (Find Cursor) find string under cursor in current working directory
	keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- (Find Buffers) list open buffers in current neovim instance
	keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- (Find Help) list available help tags
	keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>") -- (Find Diagnostics) list buffer diagnostics

	-- file browser
	keymap.set("n", "<leader>mm", "<cmd>Oil<cr>") -- (Move Many files) open file browser in current path

	-- telescope git commands
	keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- (Git Commits) list all git commits (use <cr> to checkout)
	keymap.set("n", "<leader>gh", "<cmd>Telescope git_bcommits<cr>") -- (Git History) list git commits for current file/buffer (use <cr> to checkout)
	keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- (Git Branches) list git branches (use <cr> to checkout)
	keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- (Git Status) list current changes per file with diff preview

	-- git signs
	keymap.set("n", "<leader>gl", "<cmd>Gitsigns toggle_current_line_blame<cr>") -- (Git Line) toggles git line blame

	-- diffview
	vim.keymap.set("n", "<leader>vd", "<cmd>DiffviewOpen<cr>") -- (View Diff) open diffview on current git index
	vim.keymap.set("n", "<leader>vh", "<cmd>DiffviewFileHistory %<cr>") -- (View History) view file history for current file
	-- diffview opens in a new tab so closing diffview can be done with normal tab controls

	-- harpoon
	keymap.set("n", "<leader>hh", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>') -- (Harpoon Helper) list current harpoon marks in telescope
	keymap.set("n", "<C-H>", '<cmd>lua require("harpoon.mark").add_file()<cr>') -- add current buffer to harpoon
	keymap.set("n", "<C-J>", '<cmd>lua require("harpoon.ui").nav_file(1)<cr>') -- goto specific file in mark position 1
	keymap.set("n", "<C-K>", '<cmd>lua require("harpoon.ui").nav_file(2)<cr>') -- goto specific file in mark position 2
	keymap.set("n", "<C-L>", '<cmd>lua require("harpoon.ui").nav_file(3)<cr>') -- goto specific file in mark position 3

	-- comment
	keymap.set("n", "<leader>/", ":CommentToggle<CR>", { silent = true })
	keymap.set("v", "<leader>/", ":CommentToggle<CR>", { silent = true })

	-- clipboard copy with osc52
	vim.keymap.set("v", "<leader>c", '<cmd>lua require("osc52").copy_visual()<cr>') -- (Clipboard) copy to tmux / terminal clipboard
end

---------------------
-- Lsp On Attach Keymaps (Run only when LSP is running)
---------------------
local lsp_on_attach = function(bufnr)
	-- keybind options
	local opts = { noremap = true, silent = true, buffer = bufnr }

	-- set keybinds
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
