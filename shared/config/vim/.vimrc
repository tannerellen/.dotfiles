" ===================================================
" ==================== Options ====================
" ===================================================

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Add relative numbers to each line on the left-hand side.
set relativenumber

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" Set shift width to 4 spaces.
set shiftwidth=4

" Set tab width to 4 columns.
set tabstop=4

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Ignore capital letters during search.
set ignorecase

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" ===================================================
" ==================== Keymaps  ====================
" ===================================================

" Set space as the leader key.
let mapleader = " "

" use ESC to turn off search highlighting
nnoremap <silent> <ESC> :nohlsearch<CR>

" delete single character without copying into register
nnoremap x "_x

" yank to end of line
nnoremap Y y$
" don't revert cursor on yank in visual mode
xnoremap y ygv<ESC>

" Center the cursor vertically when moving to the next word during a search.
nnoremap n nzz
nnoremap N Nzz


" center when joining lines
nnoremap J mzJ`z

" move selected lines up or down
xnoremap <silent> J :m '>+1<CR>gv=gv
xnoremap <silent> K :m '<-2<CR>gv=gv

" delete without storing in register
nnoremap <leader>d "_d
xnoremap <leader>d "_d

" close buffer
nnoremap <silent> <leader>x :bd<CR>
nnoremap <silent> <leader>X :bufdo bd<CR>

" tab management
nnoremap <silent> <leader>to :tabnew<CR>
nnoremap <silent> <leader>tx :tabclose<CR>
nnoremap <silent> <leader>tn :tabn<CR>
nnoremap <silent> <leader>tp :tabp<CR>

" ===================================================
" ==================== Colors ======================
" ===================================================
" Set the background tone.
set background=dark

" Set the color scheme.
colorscheme gruvbox
