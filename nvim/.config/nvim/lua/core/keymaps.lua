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
keymap.set("n", "<leader>gg", ":term lazygit <CR>", { silent = true }) -- opens lazygit in a new window

-- Must have remaps: https://www.youtube.com/watch?v=hSHATqh8svM
--
-- Yank to end of line
keymap.set("n", "Y", "y$")
-- Don't revert cursor on yank in visual mode
keymap.set("v", "y", "ygv<ESC>")

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

-- delete without storing in register
keymap.set("n", "<leader>d", '"_d')
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
keymap.set("n", "<leader>fd", "<cmd>Telescope diagnostics<cr>") -- list available help tags

-- telescope file browser
keymap.set("n", "<leader>nn", "<cmd>Telescope file_browser path=%:p:h<cr>") -- open file browser in current path
keymap.set("n", "<leader>nh", "<cmd>Telescope file_browser<cr>") -- open file browser in cwd

-- telescope git commands
keymap.set("n", "<leader>gc", "<cmd>Telescope git_commits<cr>") -- list all git commits (use <cr> to checkout)
keymap.set("n", "<leader>gh", "<cmd>Telescope git_bcommits<cr>") -- list git commits for current file/buffer (use <cr> to checkout)
keymap.set("n", "<leader>gb", "<cmd>Telescope git_branches<cr>") -- list git branches (use <cr> to checkout)
keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>") -- list current changes per file with diff preview
--
--Git Signs
keymap.set("n", "<leader>gl", "<cmd>Gitsigns toggle_current_line_blame<cr>") -- toggles git line blame

-- harpoon
keymap.set("n", "<C-H>", '<cmd>lua require("harpoon.mark").add_file()<cr>') -- list current harpoon marks in telescope
keymap.set("n", "<leader>hh", '<cmd>lua require("harpoon.ui").toggle_quick_menu()<cr>') -- list current harpoon marks in telescope
keymap.set("n", "<C-J>", '<cmd>lua require("harpoon.ui").nav_file(1)<cr>') -- goto specific file in mark position
keymap.set("n", "<C-K>", '<cmd>lua require("harpoon.ui").nav_file(2)<cr>') -- goto specific file in mark position
keymap.set("n", "<C-L>", '<cmd>lua require("harpoon.ui").nav_file(3)<cr>') -- goto specific file in mark position

-- comment
keymap.set("n", "<leader>/", ":CommentToggle<CR>", { silent = true })
keymap.set("v", "<leader>/", ":CommentToggle<CR>", { silent = true })

-- clipboard copy with osc52
vim.keymap.set("v", "<leader>c", '<cmd>lua require("osc52").copy_visual()<cr>')

-- diffview
vim.keymap.set("n", "<leader>mm", "<cmd>DiffviewOpen<cr>") -- open diffview on current git index
vim.keymap.set("n", "<leader>mc", "<cmd>DiffviewClose<cr>") -- close diffview on current git index
vim.keymap.set("n", "<leader>mh", "<cmd>DiffviewFileHistory %<cr>") -- view file history for current file

-- restart lsp server
keymap.set("n", "<leader>rs", ":LspRestart<CR>") -- mapping to restart lsp if necessary
