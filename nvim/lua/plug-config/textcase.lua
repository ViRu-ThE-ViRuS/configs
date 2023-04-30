return {
  'johmsalas/text-case.nvim',
  init = function()
    local utils = require('utils')
    utils.map('n', 'ses', function() require("textcase").current_word("to_snake_case") end)
    utils.map('n', 'sec', function() require("textcase").current_word("to_camel_case") end)
    utils.map('n', 'se-', function() require("textcase").current_word("to_dash_case") end)
    utils.map('n', 'seu', function() require("textcase").current_word("to_constant_case") end)
    utils.map('n', 'sep', function() require("textcase").current_word("to_pascal_case") end)
    utils.map('n', 'set', function() require("textcase").current_word("to_title_case") end)
    utils.map('n', 'sef', function() require("textcase").current_word("to_path_case") end)

    utils.map('n', 'sos', function() require("textcase").operator("to_snake_case") end)
    utils.map('n', 'soc', function() require("textcase").operator("to_camel_case") end)
    utils.map('n', 'so-', function() require("textcase").operator("to_dash_case") end)
    utils.map('n', 'sou', function() require("textcase").operator("to_constant_case") end)
    utils.map('n', 'sop', function() require("textcase").operator("to_pascal_case") end)
    utils.map('n', 'sot', function() require("textcase").operator("to_title_case") end)
    utils.map('n', 'sof', function() require("textcase").operator("to_path_case") end)
  end,
  setup = true
}
