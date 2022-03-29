
vim.cmd [[ autocmd! BufWinEnter <buffer> if winnr('$') < 2| q | endif ]]
