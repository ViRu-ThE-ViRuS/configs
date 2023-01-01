return {
    'rcarriga/nvim-notify',
    event = 'VeryLazy',
    config = function()
        local symbol_config = require('utils').editor_config.symbol_config
        local notify = require('notify')
        -- vim.notify = notify

        notify.setup({
            stages = 'fade',
            level = 'DEBUG',
            timeout = 150,
            fps = 20,
            icons = {
                ERROR = symbol_config.indicator_error,
                WARN  = symbol_config.indicator_warning,
                INFO  = symbol_config.indicator_info,
                DEBUG = symbol_config.indicator_hint,
                TRACE = symbol_config.indicator_hint
            },
            max_height = function() return math.floor(vim.o.lines * 0.75) end,
            max_width = function() return math.floor(vim.o.lines * 0.50) end,
            on_open = function(win) vim.api.nvim_win_set_config(win, { focusable = false }) end
        })
    end
}

