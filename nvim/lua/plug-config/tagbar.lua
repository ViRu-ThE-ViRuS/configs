-- deprecated
local utils = require('utils')

vim.g.tagbar_autofocus = 1
vim.g.tagbar_show_tag_count = 1
vim.g.tagbar_sort = 0
vim.g.tagbar_show_balloon = 0
vim.g.tagbar_iconchars = {'$', '-'}

utils.map('n', '<leader>k', '<cmd>TagbarToggle<cr>')
