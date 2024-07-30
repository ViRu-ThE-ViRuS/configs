return {
  'johmsalas/text-case.nvim',
  init = function()
    local utils = require('utils')

    require('utils').map({ 'n', 'x' }, 'sC', function()
      local methods = {
        ['Snake Case'] = 'to_snake_case',
        ['Camel Case'] = 'to_camel_case',
        ['Dash Case'] = 'to_dash_case',
        ['Constant Case'] = 'to_constant_case',
        ['Pascal Case'] = 'to_pascal_case',
        ['Path Case'] = 'to_path_case',
      }

      vim.ui.select(
        vim.tbl_keys(methods),
        { prompt = 'switch text case to: ', kind = 'plain_text' },
        function(choice) return choice and require('textcase').quick_replace(methods[choice]) end
      )
    end)

    local switcher_index = 1
    utils.map({ 'n', 'x' }, 'sc', function()
      local methods = {
        ['Snake Case'] = 'to_snake_case',
        ['Camel Case'] = 'to_camel_case',
        ['Constant Case'] = 'to_constant_case',
        ['Pascal Case'] = 'to_pascal_case',
      }

      local choice = vim.tbl_keys(methods)[switcher_index]
      utils.notify("Switch Case: " .. choice, 'info', { render = 'compact' })

      require('textcase').quick_replace(methods[choice])
      switcher_index = ((switcher_index + 1) % #vim.tbl_keys(methods))
      switcher_index = (switcher_index == 0 and switcher_index + 1) or switcher_index
    end)
  end,
  cmd = { 'Subs', 'TextCaseStartReplacingCommand' },
  config = { default_keymappings_enabled = false }
}
