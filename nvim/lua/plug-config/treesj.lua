return {
  'Wansmer/treesj',
  cmd = { 'TSJSplit', 'TSJJoin' },
  dependencies = { 'nvim-treesitter' },
  init = function()
    local utils = require('utils')
    -- utils.map('n', 'gS', '<cmd>TSJSplit<cr>')
    -- utils.map('n', 'gJ', '<cmd>TSJJoin<cr>')

    -- silence errors and missing configs
    utils.map('n', 'gS', '<cmd>silent! TSJSplit<cr>')
    utils.map('n', 'gJ', '<cmd>silent! TSJJoin<cr>')
  end,
  config = function()
    local lua_override = require('treesj.langs.utils').merge_preset(
      require('treesj.langs.lua'),
      {
        function_call = { target_nodes = { 'arguments' } },
        field = { target_nodes = { 'table_constructor' } },
      }
    )

    require('treesj').setup({
      use_default_keymaps = false,
      notify = true,
      langs = { lua = lua_override }
    })
  end
}
