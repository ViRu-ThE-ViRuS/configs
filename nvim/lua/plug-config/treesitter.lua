local utils = require("utils")

-- {{{ nvim-treesitter setup
local function setup_treesitter()
    require('nvim-treesitter.configs').setup({
        ensure_installed = {
            'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish', 'cmake',
            'make', 'cuda', 'rust', 'vim', 'markdown', 'javascript', 'typescript', 'tsx',
            "query"
        },

        -- NOTE(vir): nvim-yati is really good for python for now, havent noticed need for other file types yet
        indent = { enable = true, disable = { 'python', 'c', 'cpp', 'lua' } },
        yati = { enable = true, disable = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } },

        highlight = { enable = true, additional_vim_regex_highlighting = { 'markdown' } },
        matchup = { enable = true, disable_virtual_text = true },
        context_commentstring = { enable = true, enable_autocmd = false },

        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = '<m-=>',
                node_incremental = '<m-=>',
                node_decremental = '<m-->',
                -- scope_incremental = '<m-0>'
            }
        },

        textobjects = {
            select = {
                lookahead = true,
                enable = true,
                keymaps = {
                    ['af'] = '@function.outer',
                    ['if'] = '@function.inner',
                    ['ac'] = '@block.outer',
                    ['ic'] = '@block.inner',
                    ['aP'] = '@parameter.outer',
                    ['iP'] = '@parameter.inner',
                }
            },
            move = {
                enable = true,
                set_jumps = true,
                -- NOTE(vir): remaps done manually below
            },
            swap = {
                enable = true,
                swap_next = { [']p'] = "@parameter.inner" },
                swap_previous = { ['[p'] = "@parameter.inner" }
            },
            lsp_interop = {
                enable = true,
                border = 'single',
                peek_definition_code = {
                    ['gP'] = '@function.outer'
                }
            }
        },

        textsubjects = {
            enable = true,
            keymaps = {
                [';'] = 'textsubjects-smart',
                -- [';'] = 'textsubjects-container-outer',
            },
        },

        playground = { enable = true },
        query_linter = { enable = true }
    })
end

-- }}}

-- {{{ related plugin setup
-- nvim-treesitter-textobjects setup
--- @format disable-next
local function setup_textobjects()
    --- @format disable
    utils.map({ 'n', 'o', 'x' }, ']F', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@class.outer")<CR>zz')
    utils.map({ 'n', 'o', 'x' }, '[F', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@class.outer")<CR>zz')
    utils.map({ 'n', 'o', 'x' }, ']f', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@function.outer")<CR>zz')
    utils.map({ 'n', 'o', 'x' }, '[f', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@function.outer")<CR>zz')
    utils.map({ 'n', 'o', 'x' }, ']]', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@block.outer")<CR>zz')
    utils.map({ 'n', 'o', 'x' }, '[[', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@block.outer")<CR>zz')
end

-- nvim-treeclimber setup
local function setup_treeclimber()
    utils.map('n', '<leader>uf', require('nvim-treeclimber').show_control_flow)
end

-- vim-sandwich setup
local function setup_sandwich()
    vim.g['sandwich#recipes'] = require('lib/core').list_concat(
        vim.g['sandwich#default_recipes'], {
        { buns = { '( ', ' )' }, nesting = 1, match_syntax = 1, input = { ')' } },
        { buns = { '[ ', ' ]' }, nesting = 1, match_syntax = 1, input = { ']' } },
        { buns = { '{ ', ' }' }, nesting = 1, match_syntax = 1, input = { '}' } },
    })
end

-- vim-matchup setup
local function setup_matchup()
    vim.g.matchup_matchparen_deferred = 1
    vim.g.matchup_surround_enabled = 1
    vim.g.matchup_matchparen_offscreen = { method = 'popup' }
    utils.map({ 'n', 'o', 'x' }, 'Q', '<plug>(matchup-%)')
    utils.map({ 'o', 'x' }, 'iQ', '<plug>(matchup-i%)')
    utils.map({ 'o', 'x' }, 'aQ', '<plug>(matchup-a%)')
end

-- treesj setup
local function setup_treesj()
    local treesj = require('treesj')
    local treesj_utils = require('treesj/langs/utils')

    treesj.setup({
        use_default_keymaps = false,
        notify = true,
        langs = {
            lua = {
                function_call = { target_nodes = { 'arguments' } },
                return_statement = { target_nodes = { 'table_constructor' } },
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

                if_statement = { target_nodes = { 'compound_statement' } },
                declaration = { target_nodes = { 'parameter_list', 'argument_list', 'initializer_list' } },
                call_expression = { target_nodes = { 'argument_list' } },
                template_declaration = { target_nodes = { 'template_parameter_list' } }
            },
            python = {
                parameters = treesj_utils.set_preset_for_args(),
                argument_list = treesj_utils.set_preset_for_args(),
                list = treesj_utils.set_preset_for_list(),
                set = treesj_utils.set_preset_for_list(),
                tuple = treesj_utils.set_preset_for_list(),
                dictionary = treesj_utils.set_preset_for_dict({ both = { last_separator = false } }),

                assignment = { target_nodes = { 'list', 'set', 'tuple', 'dictionary' } },
                call = { target_nodes = { 'argument_list' } },
            }
        },
    })

    -- utils.map('n', 'gS', '<cmd>TSJSplit<cr>')
    -- utils.map('n', 'gJ', '<cmd>TSJJoin<cr>')

    utils.map('n', 'gS', '<cmd>silent! TSJSplit<cr>')
    utils.map('n', 'gJ', '<cmd>silent! TSJJoin<cr>')
end

-- }}}

return {
    'yioneko/nvim-yati',
    'JoosepAlviste/nvim-ts-context-commentstring',
    'RRethy/nvim-treesitter-textsubjects',
    { 'nvim-treesitter/nvim-treesitter-textobjects', config = setup_textobjects },

    { 'Dkendal/nvim-treeclimber', event = 'BufReadPost', config = setup_treeclimber },
    { 'machakann/vim-sandwich', event = 'BufReadPost', config = setup_sandwich },
    { 'andymass/vim-matchup', event = 'BufReadPost', config = setup_matchup },
    { 'Wansmer/treesj', cmd = { 'TSJSplit', 'TSJJoin' }, config = setup_treesj },
    { 'nvim-treesitter/playground', cmd = 'TSPlaygroundToggle' },

    {
        'nvim-treesitter/nvim-treesitter',
        build = ':TSUpdate',
        event = 'BufReadPost',
        config = function()
            setup_treesitter()

            -- populate all functions and lambdas into qflist
            utils.map('n', '<leader>uF', function()
                local ft = vim.api.nvim_get_option_value('ft', { scope = 'local' })
                local bufnr = vim.api.nvim_get_current_buf()

                local valid, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
                if not valid then return end

                local tree = parser:parse()[1]
                local functions = vim.treesitter.query.parse_query(
                    ft,

                    -- NOTE(vir): can add more language specific captures when needed
                    table.concat({
                        '((function_definition) @definitions)',
                        ((ft == 'lua' and '((function_declaration) @lua_declaration)') or ""),
                        ((ft == 'cpp' and '((lambda_expression) @cpp_lambda)') or ""),
                        ((ft == 'python' and '((lambda) @py_lambda)') or "")
                    }, '\n')
                )


                local qf_entries = {}
                for _, node, _ in functions:iter_captures(tree:root(), bufnr) do
                    local l1, c1, _, _ = node:start()
                    table.insert(qf_entries, {
                        bufnr = bufnr,
                        lnum = l1 + 1,
                        col = c1 + 1,
                        text = vim.split(vim.treesitter.query.get_node_text(node, bufnr), '\n')[1]
                    })
                end

                utils.qf_populate(qf_entries, 'r', 'Functions & Lambdas')
            end)

            -- go to parent
            -- utils.map('n', '[{', function()
            --     local ts = require('nvim-treesitter/ts_utils')
            --     local current = ts.get_node_at_cursor(0)
            --     local parent = current:parent()
            --     ts.goto_node(parent)
            -- end)
        end
    }
}
