local utils = require('utils')

vim.g.kommentary_create_default_mappings = false
utils.map('n', '<leader>c<space>', '<plug>kommentary_line_default', { noremap = false })
utils.map('v', '<leader>c<space>', '<plug>kommentary_visual_default', { noremap = false })
