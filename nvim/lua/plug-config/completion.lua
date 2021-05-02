local utils = require('utils')

require('compe').setup {
    debug = false,
    enabled = true,
    autocomplete = true,
    min_length = 1,
    preselect = 'enable',
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,

    source = {
        path = true,
        buffer = true,
        calc = true,
        nvim_lsp = true,
        nvim_lua = true
    }
}

utils.map('i', '<c-space>', 'compe#complete()', { silent = true, expr = true })
utils.map('i', '<cr>', 'compe#confirm("<cr>")', { silent = true, expr = true })
utils.map('i', '<c-e>', 'compe#close("<c-e>")', { silent = true, expr = true })
utils.map('i', '<c-f>', 'compe#scroll({ "delta": +4 })', { silent = true, expr = true })
utils.map('i', '<c-d>', 'compe#scroll({ "delta": -4 })', { silent = true, expr = true })

