local utils = require('utils')

vim.g.tagbar_autofocus = 1
vim.g.tagbar_iconchars = {'$', '-'}

utils.map('n', '<leader>k', '<cmd>TagbarToggle<cr>')
