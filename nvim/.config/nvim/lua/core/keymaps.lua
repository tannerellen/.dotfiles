-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps
---------------------

-- use ESC to turn off search highlighting
keymap.set("n", "<Esc>", ":nohlsearch<CR>", { silent = true })

-- delete single character without copying into register
keymap.set("n", "x", '"_x')

-- close buffer
keymap.set("n", "<leader>x", ":bd<CR>", { silent = true })

-- tab management
keymap.set("n", "<leader>to", ":tabnew<CR>", { silent = true }) -- open new tab
keymap.set("n", "<leader>tx", ":tabclose<CR>", { silent = true }) -- close current tab
keymap.set("n", "<leader>tn", ":tabn<CR>", { silent = true }) --  go to next tab
keymap.set("n", "<leader>tp", ":tabp<CR>", { silent = true }) --  go to previous tab

-- Terminal open to lazy git
keymap.set("n", "<leader>gg", ":term lazygit <CR> i", { silent = true }) -- opens lazygit in a new window

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
keymap.set("n", "<leader>/", ":CommentToggle<CR>", { silent = true })
keymap.set("v", "<leader>/", ":CommentToggle<CR>", { silent = true })

-- clipboard copy with osc52
vim.keymap.set("n", "<leader>c", require("osc52").copy_operator, { expr = true })
vim.keymap.set("n", "<leader>cc", "<leader>c_", { remap = true })
vim.keymap.set("x", "<leader>c", require("osc52").copy_visual)

-- chatGPT
vim.keymap.set("n", "<C-a>", "<cmd>ChatGPT<cr>")
vim.keymap.set("n", "<C-s>", "<cmd>ChatGPTActAs<cr>")

-- restart lsp server
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary
