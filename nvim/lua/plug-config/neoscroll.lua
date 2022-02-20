require('neoscroll').setup({
    hide_cursor = false,
    performance_mode = false
})

require('neoscroll.config').set_mappings({
    ['<c-u>'] = {'scroll', {'-vim.wo.scroll', 'true', '50'}},
    ['<c-d>'] = {'scroll', {'vim.wo.scroll', 'true', '50'}},
    ['{'] = {'scroll', {'-0.10', 'true', '50'}},
    ['}'] = {'scroll', {'0.10', 'true', '50'}},
    ['zt'] = {'zt', {'50'}},
    ['zz'] = {'zz', {'50'}},
    ['zb'] = {'zb', {'50'}}
})

local utils = require("utils")
utils.map('n', '<m-[>', '{')
utils.map('n', '<m-]>', '}')
utils.map('v', '<m-[>', '{')
utils.map('v', '<m-]>', '}')
