require('nvim-treesitter.configs').setup {
    ensure_installed = {'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish', 'cmake'},
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true
    },
    rainbow = {
        enable = true,
        extended_mode = true
    }
}

