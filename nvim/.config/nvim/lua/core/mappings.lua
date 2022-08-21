local utils = require "core.utils"

local map = utils.map

local cmd = vim.cmd

local M = {}

-- these mappings will only be called during initialization
M.misc = function()
   local function non_config_mappings()
      -- Don't copy the replaced text after pasting in visual mode
      map("v", "p", '"_dP')

      -- Allow moving the cursor through wrapped lines with j, k, <Up> and <Down>
      -- http://www.reddit.com/r/vim/comments/2k4cbr/problem_with_gj_and_gk/
      -- empty mode is same as using :map
      -- also don't use g[j|k] when in operator pending mode, so it doesn't alter d, y or c behaviour
      map("", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
      map("", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })
      map("", "<Down>", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true })
      map("", "<Up>", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true })

      -- use ESC to turn off search highlighting
      map("n", "<Esc>", ":noh <CR>")
   end

   local function optional_mappings()
      -- don't yank text on cut ( x )
	  -- map({ "n", "v" }, "x", '"_x')

      -- don't yank text on delete ( dd )
      -- map({ "n", "v" }, "dd", '"_dd')

      -- navigation within insert mode
	 map("i", "<C-h>", "<Left>")
	 map("i", "<C-e>", "<End>")
	 map("i", "<C-l>", "<Right>")
	 map("i", "<C-k>", "<Up>")
	 map("i", "<C-j>", "<Down>")
	 map("i", "<C-a>", "<ESC>^i")

	 -- Must have remaps: https://www.youtube.com/watch?v=hSHATqh8svM
	 --
	 -- Yank to end of line
	 map("n", "Y", "y$")

	 -- Center when navigating search result
	 map("n", "n", "nzz")
	 map("n", "N", "Nzz")
	 -- Center when joining lines
	 map("n", "J", "mzJ`z")

	 -- Move selected lines up or down
	 map("v", "J", ":m '>+1<CR>gv=gv")
	 map("v", "K", ":m '<-2<CR>gv=gv")

	 -- greatest remap ever
	 map("x", "<leader>p", "\"_dP")

	 -- next greatest remap ever 
	 map("n", "<leader>Y", "\"+Y", { noremap = false })
	 map("n", "<leader>y", "\"+y")
	 map("v", "<leader>y", "\"+y")

	 map("n", "<leader>d", "\"_d")
	 map("v", "<leader>d", "\"_d")

     map("v", "<leader>d", "\"_d")
   end

   local function required_mappings()
      map("n", "<leader>x", ":lua require('core.utils').close_buffer() <CR>") -- close  buffer
      map("n", "<C-a>", ":%y+ <CR>") -- copy whole file content
      map("n", "<S-t>", ":enew <CR>") -- new buffer
      map("n", "<C-t>b", ":tabnew <CR>") -- new tabs
      map("n", "<leader>n", ":set nu! <CR>") -- toggle numbers

      -- Add Packer commands because we are not loading it at startup
      cmd "silent! command PackerClean lua require 'plugins' require('packer').clean()"
      cmd "silent! command PackerCompile lua require 'plugins' require('packer').compile()"
      cmd "silent! command PackerInstall lua require 'plugins' require('packer').install()"
      cmd "silent! command PackerStatus lua require 'plugins' require('packer').status()"
      cmd "silent! command PackerSync lua require 'plugins' require('packer').sync()"
      cmd "silent! command PackerUpdate lua require 'plugins' require('packer').update()"

   end

   non_config_mappings()
   optional_mappings()
   required_mappings()
end

-- below are all plugin related mappings

-- M.better_escape = function()
--    return { "jk" }
-- end

M.bufferline = function()
   map("n", "<TAB>", ":BufferLineCycleNext <CR>")
   map("n", "<S-Tab>", ":BufferLineCyclePrev <CR>")
end

M.comment = function()
   local m = "<leader>/"
   map("n", m, ":CommentToggle <CR>")
   map("v", m, ":CommentToggle <CR>")
end

M.nvimtree = function()
   map("n", "<C-n>", ":NvimTreeToggle <CR>")
end

M.formatter = function()
   map("n", "<leader>fm", ":Format <CR>")
end

M.telescope = function()
   map("n", "<leader>fb", ":Telescope buffers <CR>")
   map("n", "<leader>ff", ":Telescope find_files <CR>")
   map("n", "<leader>fa", ":Telescope find_files no_ignore=true hidden=true <CR>")
   map("n", "<leader>cm", ":Telescope git_commits <CR>")
   map("n", "<leader>gt", ":Telescope git_status <CR>")
   map("n", "<leader>br", ":Telescope git_branches <CR>")
   map("n", "<leader>fh", ":Telescope help_tags <CR>")
   map("n", "<leader>fw", ":Telescope live_grep <CR>")
   map("n", "<leader>fo", ":Telescope oldfiles <CR>")
end

M.harpoon = function()
   map("n", "<leader>ha", ":lua require('harpoon.mark').add_file() <CR>")
   map("n", "<leader>hm", ":lua require('harpoon.ui').toggle_quick_menu() <CR>")
   map("n", "<leader>b", ":lua require('harpoon.ui').nav_next() <CR>")
   map("n", "<leader>B", ":lua require('harpoon.ui').nav_prev() <CR>")
   
end

M.git_blame = function()
   map("n", "<leader>gb", ":GitBlameToggle <CR>")
end

M.clipboard = function ()

   map("n", "<leader>c", ":lua require('osc52').copy_operator() <CR>")
   map("x", "<leader>c", ":lua require('osc52').copy_visual() <CR>")
	-- vim.keymap.set('n', '<leader>c', require('osc52').copy_operator, {expr = true})
-- vim.keymap.set('n', '<leader>cc', '<leader>c_', {remap = true})
-- vim.keymap.set('x', '<leader>c', require('osc52').copy_visual)
end

return M
