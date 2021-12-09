require('nvim-treesitter.configs').setup {
    ensure_installed = {'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish', 'cmake'},
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
                ['af'] = '@function.outer',
                ['if'] = '@function.inner',
                ['ac'] = '@class.outer',
                ['ic'] = '@class.inner',
            }
        }
    }
}

