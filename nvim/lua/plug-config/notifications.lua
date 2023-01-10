local symbol_config = require('utils').editor_config.symbol_config

return {
    'rcarriga/nvim-notify',
    opts = {
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
        max_height = function() return math.floor(vim.o.lines * 0.50) end,
        max_width = function() return math.floor(vim.o.columns * 0.45) end,
        on_open = function(win)
            vim.api.nvim_win_set_config(win, { focusable = false })
            -- vim.api.nvim_set_option_value('statuscolumn', '', { win = win })
        end
    }
}
