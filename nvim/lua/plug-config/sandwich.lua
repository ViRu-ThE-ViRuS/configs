return {
  'machakann/vim-sandwich',
  dependencies = { 'nvim-treesitter' },
  config = function()
    vim.g['sandwich#recipes'] = require('lib/core').list_concat(
      vim.g['sandwich#default_recipes'], {
        -- add
        { buns = { '( ', ' )' },           nesting = 1, match_syntax = 1, input = { ')' } },
        { buns = { '[ ', ' ]' },           nesting = 1, match_syntax = 1, input = { ']' } },
        { buns = { '{ ', ' }' },           nesting = 1, match_syntax = 1, input = { '}' } },

        -- remove or replace
        { buns = { '{\\s*', '\\s*}' },     nesting = 1, match_syntax = 1, regex = 1,      kind = { 'delete', 'replace', 'textobj' }, action = { 'delete' }, input = { '{' } },
        { buns = { '\\[\\s*', '\\s*\\]' }, nesting = 1, match_syntax = 1, regex = 1,      kind = { 'delete', 'replace', 'textobj' }, action = { 'delete' }, input = { '[' } },
        { buns = { '(\\s*', '\\s*)' },     nesting = 1, match_syntax = 1, regex = 1,      kind = { 'delete', 'replace', 'textobj' }, action = { 'delete' }, input = { '(' } },
      })
  end,
}
