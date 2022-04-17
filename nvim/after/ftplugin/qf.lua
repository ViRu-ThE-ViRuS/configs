vim.opt_local.buflisted = false
vim.opt_local.number = true
vim.opt_local.signcolumn = 'yes'
vim.opt_local.bufhidden = 'wipe'

vim.keymap.set('n', '<c-w>v', '<c-w><cr><c-w>L', { noremap = true, buffer = 0})
vim.keymap.set('n', '<c-w>x', '<c-w><cr><c-w>K', { noremap = true, buffer = 0})
vim.keymap.set('n', '<c-o>', '<cmd>wincmd p<cr>', { noremap = true, buffer = 0 })

vim.cmd [[ autocmd! BufEnter <buffer> if winnr('$') < 2 | q | endif ]]

