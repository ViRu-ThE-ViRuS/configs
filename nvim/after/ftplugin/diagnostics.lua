vim.opt_local.buflisted = false
vim.opt_local.number = true
vim.opt_local.signcolumn = 'no'
vim.opt_local.bufhidden = 'wipe'
vim.opt_local.filetype = 'diagnostics'
vim.opt_local.syntax = 'qf'

vim.cmd [[autocmd! BufEnter <buffer> if winnr('$') < 2| q | endif]]
