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

    -- rainbow = { enable = true, extended_mode = true },
    -- incremental_selection = {
    --     enable = true,
    --     keymaps = {
    --         init_selection = 'gm=',
    --         node_incremental = 'gm=',
    --         node_decremental = 'gm-'
    --     }
    -- },
}

-- vim-matchup
vim.g.matchup_matchparen_offscreen = { method = 'popup' }
