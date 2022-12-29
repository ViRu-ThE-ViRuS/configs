return {
    'b3nj5m1n/kommentary',
    event = 'BufReadPost',
    config = function()
        local utils = require('utils')
        local kommentary = require('kommentary.config')

        -- NOTE(vir): nvim-ts-context-commentstring setup
        kommentary.configure_language("default", {
            prefer_single_line_comments = true,
            hook_function = function() require('ts_context_commentstring.internal').update_commentstring() end,
        })

        kommentary.configure_language("asm", {
            single_line_comment_string = ';',
            multi_line_comment_strings = false
        })

        kommentary.configure_language({ 'javascript', 'javascriptreact', 'typescriptreact' }, {
            single_line_comment_string = 'auto',
            multi_line_comment_strings = 'auto',
        })

        vim.g.kommentary_create_default_mappings = false
        utils.map('n', '<leader>c<space>', '<plug>kommentary_line_default', { noremap = false })
        utils.map('v', '<leader>c<space>', '<plug>kommentary_visual_default', { noremap = false })

        -- NOTE(vir): holy shit this is amazing
        -- `gc` toggles comments on last visual selection it,
        -- without moving cursor position
        utils.unmap('n', 'gcc')
        utils.map('n', 'gc', "<cmd>normal mCgvgc'C<cr>")
    end
}

