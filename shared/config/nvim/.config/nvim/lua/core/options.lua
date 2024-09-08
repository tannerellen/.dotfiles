local opt = vim.opt -- for conciseness
-- local g = vim.g -- for global settings

-- line numbers
opt.relativenumber = true -- show relative line numbers
opt.number = true -- shows absolute line number on cursor line (when relative number is on)
opt.numberwidth = 2 -- line number gutter width

-- tabs & indentation
opt.tabstop = 4 -- spaces for tab
opt.shiftwidth = 4 -- spaces for indent width
opt.expandtab = false -- expand tab to spaces
opt.autoindent = true -- copy indent from current line when starting new one
opt.smartindent = true

-- line wrapping
opt.wrap = true -- enable line wrapping

-- folding
opt.foldmethod = "indent"
opt.foldlevel = 99 -- prevent files from auto folding when opened but still allow individual folds with zc and za

-- search settings
opt.ignorecase = true -- ignore case when searching
opt.smartcase = true -- if you include mixed case in your search, assumes you want case-sensitive

-- cursor line
opt.cursorline = true -- highlight the current cursor line

-- command height
opt.cmdheight = 1 -- set to 0 to hide command line unless used

-- disable nvim intro
opt.shortmess:append("sI")

-- enable undo file with undo history
opt.undofile = true

-- time in milliseconds to wait for a mapped sequence to complete
opt.timeoutlen = 500

-- interval for writing swap file to disk, also used by gitsigns
-- Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
-- delays and poor user experience.
opt.updatetime = 250

-- appearance

-- turn on termguicolors for modern colorschemes to work
-- (have to use iterm2 or any other true color terminal)
opt.termguicolors = true
opt.background = "dark" -- colorschemes that can be light or dark will be made dark
opt.signcolumn = "yes" -- show sign column so that text doesn't shift

-- disable tilde on end of buffer: https://github.com/  neovim/neovim/pull/8546#issuecomment-643643758
opt.fillchars = { eob = " " }

-- draw a column at line character limit
opt.colorcolumn:append("80")

-- backspace
opt.backspace = "indent,eol,start" -- allow backspace on indent, end of line or insert mode start position

-- clipboard
opt.clipboard:append("unnamedplus") -- use system clipboard as default register

-- split windows
opt.splitright = true -- split vertical window to the right
opt.splitbelow = true -- split horizontal window to the bottom

opt.iskeyword:append("-") -- consider string-string as whole word
