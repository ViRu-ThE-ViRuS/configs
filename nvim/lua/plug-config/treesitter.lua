require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish', 'cmake',
        'make', 'cuda', 'markdown', 'rust', 'vim'
    },
    highlight = {enable = true, additional_vim_regex_highlighting = false},
    indent = {enable = false},
    matchup = {enable = true, disable_virtual_text = true},
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@conditional.outer',
                ['ic'] = '@conditional.inner'
            }
        }
    },

    -- rainbow = {enable = true, extended_mode = true},
    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = 'ge=',
            node_incremental = 'ge=',
            node_decremental = 'ge-',
            scope_incremental = 'ge+'
        }
    }
}

-- NOTE(vir): related plugin setup

-- vim-matchup
vim.g.matchup_matchparen_offscreen = {method = 'popup'}

-- vim-sandwich
vim.g['sandwich#recipes'] = require('lib/core').list_concat(
                                vim.g['sandwich#default_recipes'], {
        {buns = {'( ', ' )'}, nesting = 1, match_syntax = 1, input = {')'}},
        {buns = {'[ ', ' ]'}, nesting = 1, match_syntax = 1, input = {']'}},
        {buns = {'{ ', ' }'}, nesting = 1, match_syntax = 1, input = {'}'}},
    })
