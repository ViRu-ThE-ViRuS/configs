require('neoscroll').setup({
    hide_cursor = false,
    performance_mode = false,
    cursor_scrools_alone = true
})

require('neoscroll.config').set_mappings({
    ['<c-u>'] = {'scroll', {'-20', 'true', '50'}},
    ['<c-d>'] = {'scroll', {'20', 'true', '50'}},
    ['{'] = {'scroll', {'-5', 'true', '10'}},
    ['}'] = {'scroll', {'5', 'true', '10'}},
    ['zt'] = {'zt', {'50'}},
    ['zz'] = {'zz', {'50'}},
    ['zb'] = {'zb', {'50'}}
})

