local utils = require('utils')

vim.g.NERDCreateDefaultMappings = 0
utils.map('n', '<leader>c<space>', '<plug>NERDCommenterToggle', { noremap = false })
utils.map('v', '<leader>c<space>', '<plug>NERDCommenterToggle', { noremap = false })

