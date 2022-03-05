local utils = require('utils')
local kommentary = require('kommentary.config')

kommentary.configure_language("default", {
    prefer_single_line_comments = true,
})

kommentary.configure_language("asm", {
    single_line_comment_string = ';',
    multi_line_comment_strings = false
})

vim.g.kommentary_create_default_mappings = false
utils.map('n', '<leader>c<space>', '<plug>kommentary_line_default', { noremap = false })
utils.map('v', '<leader>c<space>', '<plug>kommentary_visual_default', { noremap = false })
