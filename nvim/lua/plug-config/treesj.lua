local utils = require('utils')
local treesj = require('treesj')
local treesj_utils = require('treesj/langs/utils')

treesj.setup({
    use_default_keymaps = false,
    notify = true,
    langs = {
        cpp = {
            parameter_list = treesj_utils.set_preset_for_args(),
            argument_list = treesj_utils.set_preset_for_args(),
            initializer_list = treesj_utils.set_preset_for_list(),
        },
        python = {
            parameters = treesj_utils.set_preset_for_args(),
            argument_list = treesj_utils.set_preset_for_args(),
        }
    },
})

utils.map('n', 'gS', '<cmd>TSJSplit<cr>')
utils.map('n', 'gJ', '<cmd>TSJJoin<cr>')

