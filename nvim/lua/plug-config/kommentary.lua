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

-- NOTE(vir): holy shit this is amazing
-- `gc` selects the last visual selection, toggles comments on it, and returns
-- cursor to current position
utils.unmap('n', 'gcc')
utils.map('n', 'gc', "<cmd>normal mCgvgc'C<cr>")

