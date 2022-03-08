local symbol_config = require('utils').symbol_config
require('notify').setup({
    stages = 'fade',
    timeout = 500,
    icons = {
        ERROR = symbol_config.indicator_error,
        WARN  = symbol_config.indicator_warning,
        INFO  = symbol_config.indicator_info,
        DEBUG = symbol_config.indicator_hint,
        TRACE = symbol_config.indicator_hint
    }
})
