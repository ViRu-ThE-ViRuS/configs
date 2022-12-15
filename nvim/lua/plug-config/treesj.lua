local utils = require('utils')
local treesj = require('treesj')
local treesj_utils = require('treesj/langs/utils')

-- TODO(vir): disable empty cases when plugin author updates
treesj.setup({
    use_default_keymaps = false,
    notify = true,
    langs = {
        lua = {
            function_call = { target_nodes = { 'arguments' } },
            return_statement = { target_nodes = { 'table_constructor' } }
        },
        cpp = {
            parameter_list = treesj_utils.set_preset_for_args(),
            argument_list = treesj_utils.set_preset_for_args(),
            template_argument_list = treesj_utils.set_preset_for_args(),
            template_parameter_list = treesj_utils.set_preset_for_args(),
            initializer_list = treesj_utils.set_preset_for_list(),
            compound_statement = treesj_utils.set_preset_for_statement({
                both = {
                    separator = ';',
                    last_separator = true,
                    no_format_with = { 'compound_statement' },
                    recursive = false,
                },
            }),

            if_statement = { target_nodes = { 'compound_statement' }},
            declaration = { target_nodes = { 'parameter_list', 'argument_list', 'initializer_list' } },
            call_expression = { target_nodes = { 'argument_list' }},
            template_declaration = { target_nodes = { 'template_parameter_list' }}
        },
        python = {
            parameters = treesj_utils.set_preset_for_args(),
            argument_list = treesj_utils.set_preset_for_args(),
            list = treesj_utils.set_preset_for_list(),
            set = treesj_utils.set_preset_for_list(),
            tuple = treesj_utils.set_preset_for_list(),
            dictionary = treesj_utils.set_preset_for_dict({ both = { last_separator = false }}),

            assignment = { target_nodes = { 'list', 'set', 'tuple', 'dictionary' } },
            call = { target_nodes = { 'argument_list' } },
        }
    },
})

-- utils.map('n', 'gS', '<cmd>TSJSplit<cr>')
-- utils.map('n', 'gJ', '<cmd>TSJJoin<cr>')

utils.map('n', 'gS', '<cmd>silent! TSJSplit<cr>')
utils.map('n', 'gJ', '<cmd>silent! TSJJoin<cr>')

