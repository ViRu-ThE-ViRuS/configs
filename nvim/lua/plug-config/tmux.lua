return {
    'aserowy/tmux.nvim',
    event = 'UIEnter',
    opts = {
        copy_sync = {
            enable = true,
            redirect_to_clipboard = false
        },
        navigation = { enable_default_keybindings = true },
        resize = { enable_default_keybindings = false }
    }
}

