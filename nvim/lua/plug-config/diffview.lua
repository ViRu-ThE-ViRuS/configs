local utils = require('utils')
local callback = require('diffview/config').diffview_callback

require('diffview').setup {
    file_panel = { position = 'right', listing_style = 'list' },
    key_bindings = {
        disable_defaults = true,
        view = {
            ['e']          = callback('goto_file'),
            ['<leader>gh'] = callback('toggle_files')
        },
        file_panel = {
            ['j']          = callback('next_entry'),
            ['k']          = callback('prev_entry'),
            ['<cr>']       = callback('select_entry'),

            ["]c"]         = callback("select_next_entry"),
            ["[c"]         = callback("select_prev_entry"),

            ['s']          = callback('toggle_stage_entry'),
            ['S']          = callback('stage_all'),
            ['U']          = callback('unstage_all'),
            ['X']          = callback('restore_entry'),
            ['R']          = callback('refresh_files'),

            ['e']          = callback('goto_file'),
            ['<leader>gh'] = callback('toggle_files')
        },
        file_history_panel = {
            ['zR']         = callback('open_all_folds'),
            ['zM']         = callback('close_all_folds'),

            ["]c"]         = callback("select_next_entry"),
            ["[c"]         = callback("select_prev_entry"),

            ['j']          = callback('next_entry'),
            ['k']          = callback('prev_entry'),
            ['<cr>']       = callback('select_entry'),

            ['e']          = callback('goto_file'),
            ['<leader>gh'] = callback('toggle_files')
        },
        options_panel = { }
    },
}

utils.map('n', '<leader>gh', '<cmd>DiffviewOpen<cr>')
utils.map('n', '<leader>gH', '<cmd>DiffviewFileHistory<cr>')

