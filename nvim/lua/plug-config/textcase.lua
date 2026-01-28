return {
  'johmsalas/text-case.nvim',
  init = function()
    local utils = require('utils')

    utils.map({ 'n', 'x' }, 'sC', function()
      local methods = {
        ['Camel Case'] = 'to_camel_case',
        ['Constant Case'] = 'to_constant_case',
        ['Dash Case'] = 'to_dash_case',
        ['Lower Case'] = 'to_lower_case',
        ['Pascal Case'] = 'to_pascal_case',
        ['Path Case'] = 'to_path_case',
        ['Snake Case'] = 'to_snake_case',
        ['Upper Case'] = 'to_upper_case'
      }

      vim.ui.select(
        vim.tbl_keys(methods),
        { prompt = 'switch text case to: ', kind = 'plain_text' },
        function(choice) return choice and require('textcase').quick_replace(methods[choice]) end
      )
    end)

    -- NOTE(vir): make dot repeat the last choice
    -- source https://www.vikasraj.dev/blog/vim-dot-repeat
    local switcher_index = 1
    _G._switch_case = function(motion)
      local is_visual = string.match(motion or '', '[vV]')
      if not is_visual and motion == nil then
        vim.opt.operatorfunc = 'v:lua._switch_case'
        return 'g@l'
      end

      local methods = {
        [1] = 'to_snake_case',
        [2] = 'to_upper_case',
        [3] = 'to_lower_case',
        [4] = 'to_camel_case',
        [5] = 'to_pascal_case',
      }

      if is_visual then vim.api.nvim_input('gv') end
      local choice = methods[switcher_index]
      print("Switch Case: " .. choice)

      require('textcase').quick_replace(choice)
      switcher_index = (switcher_index < vim.tbl_count(methods) and (switcher_index + 1)) or 1
    end

    utils.map('n', 'sc', _G._switch_case, { expr = true })
    utils.map('x', 'sc', '<esc><cmd>lua _G._switch_case(vim.fn.visualmode())<cr>', { expr = true })
  end,
  cmd = { 'Subs', 'TextCaseStartReplacingCommand' },
  opts = { default_keymappings_enabled = false }
}
