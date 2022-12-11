-- Don't show any numbers inside terminals
vim.cmd([[ 
  augroup terminal_line_numbers
    autocmd!
	autocmd TermOpen term://* setlocal nonumber norelativenumber | setfiletype terminal 
  augroup end
]])
