vim.opt_local.buflisted = false
vim.opt_local.number = true
vim.opt_local.signcolumn = 'yes'
vim.opt_local.bufhidden = 'wipe'

vim.keymap.set('n', '<leader>q', '<cmd>cclose<cr>', { noremap = true, buffer = 0 })
vim.cmd [[autocmd! BufEnter <buffer> if winnr('$') < 2| q | endif]]
