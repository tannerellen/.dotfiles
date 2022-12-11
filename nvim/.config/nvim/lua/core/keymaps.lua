-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- use ESC to turn off search highlighting
keymap.set("n", "<Esc>", ":nohlsearch<CR>")

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- close bugger
keymap.set("n", "<leader>x", ":bd<CR>")

-- window management
keymap.set("n", "<leader>sv", "<C-w>v") -- split window vertically
keymap.set("n", "<leader>sh", "<C-w>s") -- split window horizontally
keymap.set("n", "<leader>se", "<C-w>=") -- make split windows equal width & height
keymap.set("n", "<leader>sx", ":close<CR>") -- close current split window

keymap.set("n", "<leader>to", ":tabnew<CR>") -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>") -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>") --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>") --  go to previous tab

-- Terminal open to lazy git
keymap.set("n", "<leader>gg", ":term lazygit <CR> i") -- opens lazygit in a new window

-- Must have remaps: https://www.youtube.com/watch?v=hSHATqh8svM
--
-- Yank to end of line
keymap.set("n", "Y", "y$")

-- Center when navigating search result
keymap.set("n", "n", "nzz")
keymap.set("n", "N", "Nzz")

-- Center when joining lines
keymap.set("n", "J", "mzJ`z")

-- Move selected lines up or down
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- greatest remap ever
keymap.set("x", "<leader>p", '"_dP')

-- next greatest remap ever
keymap.set("n", "<leader>Y", '"+Y', { noremap = false })
keymap.set("n", "<leader>y", '"+y')
keymap.set("v", "<leader>y", '"+y')

keymap.set("n", "<leader>d", '"_d')
keymap.set("v", "<leader>d", '"_d')

keymap.set("v", "<leader>d", '"_d')

----------------------
-- Plugin Keybinds
----------------------

-- telescope
keymap.set("n", "<leader>ff", "<cmd>Telescope find_files<cr>") -- find files within current working directory, respects .gitignore
keymap.set("n", "<leader>fw", "<cmd>Telescope live_grep<cr>") -- find string in current working directory as you type
keymap.set("n", "<leader>fc", "<cmd>Telescope grep_string<cr>") -- find string under cursor in current working directory
keymap.set("n", "<leader>fb", "<cmd>Telescope buffers<cr>") -- list open buffers in current neovim instance
keymap.set("n", "<leader>fh", "<cmd>Telescope help_tags<cr>") -- list available help tags

-- telescope git commands
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout) ["gc" for git commits]
keymap.set("n", "<leader>gfc", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout) ["gfc" for git file commits]
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout) ["gb" for git branch]
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview ["gs" for git status]

-- comment
keymap.set("n", "<leader>/", ":CommentToggle<CR>")
keymap.set("v", "<leader>/", ":CommentToggle<CR>")

-- restart lsp server
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary
