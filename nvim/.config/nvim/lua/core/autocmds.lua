vim.cmd([[
  augroup terminal_settings
    autocmd!

  	" Don't show line numbers in terminal
	autocmd TermOpen term://* setlocal nonumber norelativenumber | setfiletype terminal 

  	" the following 2 lines can be enabled to automatically enter inert mode when openeing a terminal
    " autocmd BufWinEnter,WinEnter term://* startinsert
    " autocmd BufLeave term://* stopinsert

    " Ignore various filetypes as those will close terminal automatically
    " Ignore fzf, ranger, coc
  	" When the terminal app is closed then input return to close exit process and return to buffer
    autocmd TermClose term://*
          \ if (expand('<afile>') !~ "fzf") && (expand('<afile>') !~ "ranger") && (expand('<afile>') !~ "coc") |
          \   call nvim_input('<CR>')  |
          \ endif
  augroup END
]])
