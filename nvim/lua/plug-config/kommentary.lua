local utils = require('utils')

require('kommentary.config').configure_language("default", {
    prefer_single_line_comments = true,
})

vim.g.kommentary_create_default_mappings = false
utils.map('n', '<leader>c<space>', '<plug>kommentary_line_default', { noremap = false })
utils.map('v', '<leader>c<space>', '<plug>kommentary_visual_default', { noremap = false })
