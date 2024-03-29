return {
  'b3nj5m1n/kommentary',
  event = 'BufReadPre',
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

    kommentary.configure_language("glsl", {
      single_line_comment_string = '//',
      multi_line_comment_strings = false
    })

    kommentary.configure_language({ 'javascript', 'javascriptreact', 'typescriptreact' }, {
      single_line_comment_string = 'auto',
      multi_line_comment_strings = 'auto',
    })

    vim.g.kommentary_create_default_mappings = false
    utils.map('n', '<leader>c<space>', '<plug>kommentary_line_default', { noremap = false })
    utils.map('v', '<leader>c<space>', '<plug>kommentary_visual_default', { noremap = false })

    -- holy shit this is amazing
    -- `gc` selects the last visual selection, toggles comments on it, and returns
    -- cursor to current position
    utils.unmap('n', 'gcc')
    utils.map('n', 'gc', "<cmd>normal mCgvgc'C<cr>")
  end
}
