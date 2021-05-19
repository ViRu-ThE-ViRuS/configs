require('nvim-treesitter.configs').setup {
    -- ensure_installed = 'maintained',
    highlight = {
        enable = true,
        additional_vim_regex_highlighting = true
    },
    rainbow = {
        enable = true,
        extended_mode = true
    }
}

