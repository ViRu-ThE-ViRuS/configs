require('nvim-treesitter.configs').setup {
    ensure_installed = {
        'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish', 'cmake',
        'make', 'cuda', 'markdown', 'rust', 'vim'
    },
    highlight = {enable = true, additional_vim_regex_highlighting = false},
    indent = { enable = false },
    -- rainbow = { enable = true, extended_mode = true },
    matchup = { enable = true, disable_virtual_text = true },
    textobjects = {
        select = {
            enable = true,
            lookahead = true,
            keymaps = {
                ['ab'] = '@class.outer',
                ['ib'] = '@class.inner',
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@conditional.outer',
                ['ic'] = '@conditional.inner'
            }
        }
    }
}

-- vim-matchup
vim.g.matchup_matchparen_offscreen = { method = 'popup' }
