vim.g['sandwich#recipes'] = require('lib/core').list_concat(
    vim.g['sandwich#default_recipes'], {
    { buns = { '( ', ' )' }, nesting = 1, match_syntax = 1, input = { ')' } },
    { buns = { '[ ', ' ]' }, nesting = 1, match_syntax = 1, input = { ']' } },
    { buns = { '{ ', ' }' }, nesting = 1, match_syntax = 1, input = { '}' } },
})
