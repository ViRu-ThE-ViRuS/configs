local utils = require("utils")

require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish', 'cmake',
        'make', 'cuda', 'rust', 'vim', 'markdown', 'javascript', 'typescript', 'tsx'
    },

    -- indent = {enable = true},
    indent = {enable = true, }, --  disable={'python', 'c', 'cpp', 'lua', 'javascript', 'javascriptreact', 'typescript', 'tsx'}},

    highlight = {enable = true, additional_vim_regex_highlighting = {'markdown'}},
    matchup = {enable = true, disable_virtual_text = true},
    context_commentstring = {enable = true, enable_autocmd = false},
    yati = {enable = true, disable = {'lua', 'python', 'cpp', 'c'}},

    incremental_selection = {
        enable = true,
        keymaps = {
            init_selection = '<m-=>',
            node_incremental = '<m-=>',
            node_decremental = '<m-->',
            -- scope_incremental = '<m-0>'
        }
    },

    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@block.outer',
                ['ic'] = '@block.inner',
            }
        },
        move = {
            enable = true,
            set_jumps = true,
            -- NOTE(vir): remaps done manually below
        },
        swap = {
            enable = true,
            swap_next = { [']p'] = "@parameter.inner" },
            swap_previous = { ['[p'] = "@parameter.inner" }
        }
    },

    textsubjects = {
        enable = true,
        keymaps = {
            [';'] = 'textsubjects-smart',
            -- [';'] = 'textsubjects-container-outer',
        },
    },

    playground = { enable = true },
    query_linter = { enable = true }
}

-- go to parent
-- utils.map('n', '[[', function()
--     local ts = require('nvim-treesitter/ts_utils')
--     ts.goto_node(ts.get_node_at_cursor(0):parent())
-- end)

-- text-subjects : move + center
utils.map({'n', 'o', 'x'}, ']F', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@class.outer")<CR>zz')
utils.map({'n', 'o', 'x'}, '[F', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@class.outer")<CR>zz')
utils.map({'n', 'o', 'x'}, ']f', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@function.outer")<CR>zz')
utils.map({'n', 'o', 'x'}, '[f', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@function.outer")<CR>zz')
utils.map({'n', 'o', 'x'}, ']]', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@block.outer")<CR>zz')
utils.map({'n', 'o', 'x'}, '[[', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@block.outer")<CR>zz')

-- NOTE(vir): related plugin setup
-- vim-matchup
vim.g.matchup_matchparen_deferred = 1
vim.g.matchup_surround_enabled = 1
vim.g.matchup_matchparen_offscreen = {method = 'popup'}
utils.map({'n', 'o', 'x'}, 'Q', '<plug>(matchup-%)')
utils.map({'o', 'x'}, 'iQ', '<plug>(matchup-i%)')
utils.map({'o', 'x'}, 'aQ', '<plug>(matchup-a%)')

-- vim-sandwich
vim.g['sandwich#recipes'] = require('lib/core').list_concat(
    vim.g['sandwich#default_recipes'], {
        {buns = {'( ', ' )'}, nesting = 1, match_syntax = 1, input = {')'}},
        {buns = {'[ ', ' ]'}, nesting = 1, match_syntax = 1, input = {']'}},
        {buns = {'{ ', ' }'}, nesting = 1, match_syntax = 1, input = {'}'}}
    })

