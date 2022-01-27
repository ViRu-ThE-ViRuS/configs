require('nvim-treesitter.configs').setup {
    ensure_installed = {'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish', 'cmake', 'make', 'cuda', 'markdown'},
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = false
    },
    rainbow = {
        enable = true,
        extended_mode = true
    },
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

