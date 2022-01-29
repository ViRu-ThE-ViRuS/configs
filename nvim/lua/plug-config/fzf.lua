local utils = require("utils")
local actions = require("fzf-lua").actions

require("fzf-lua").setup({
    winopts = {
        split = 'belowright new',
        fullscreen = false,
        preview = {
            default = 'bat_native',
            horizontal = 'right:50%',
            vertical = 'down:50%',
            layout = 'horizontal'
        },
        on_create = function()
            vim.opt_local.buflisted = false
            vim.opt_local.bufhidden = 'wipe'
            vim.opt_local.signcolumn = 'no'
            -- vim.opt_local.statusline = require('statusline').StatusLine('FZF')
        end
    },
    keymap = {
        fzf = {
            ['ctrl-a'] = 'select-all',
            ['ctrl-d'] = 'deselect-all'
        }
    },
    fzf_opts = { ['--layout'] = 'default' },
    previewers = {
        bat = {
            cmd = "bat",
            args = "--style=numbers,changes --color always",
            theme = 'Coldark-Dark',
        }
    },
    files = {
        multiprocess = true,
        cmd = 'rg --files --follow --smart-case --hidden --no-ignore -g "!{.DS_Store,.cache,venv,.git,.clangd,.ccls-cache}" 2> /dev/null',
        actions = {
            ['default'] = actions.file_edit,
            ['ctrl-x'] = actions.file_split,
            ['ctrl-v'] = actions.file_vsplit,
            ['ctrl-q'] = require('utils').qf_populate
        }
    },
    git = {
        files = {
            multiprocess = true,
            actions = {
                ['default'] = actions.file_edit,
                ['ctrl-x'] = actions.file_split,
                ['ctrl-v'] = actions.file_vsplit,
                ['ctrl-q'] = require('utils').qf_populate
            }
        }
    },
    buffers = {
        actions = {
            ['default'] = actions.buf_edit,
            ['ctrl-x'] = actions.buf_split,
            ['ctrl-v'] = actions.buf_vsplit,
            ['ctrl-q'] = { actions.buf_del, actions.resume }
        }
    },
    grep = {
        rg_opts = "--hidden --column --line-number --no-heading --color=always --smart-case -g '!{.DS_Store,.cache,venv,.git,.clangd,.ccls-cache}'",
        experimental = false,
        multiprocess = true,
        actions = {
            ['default'] = actions.file_edit,
            ['ctrl-x'] = actions.file_split,
            ['ctrl-v'] = actions.file_vsplit,
            ['ctrl-q'] = require('lib/misc').fzf_to_qf
        }
    },
    lsp = {
        actions = {
            ['default'] = actions.file_edit,
            ['ctrl-x'] = actions.file_split,
            ['ctrl-v'] = actions.file_vsplit,
            ['ctrl-q'] = require('lib/misc').fzf_to_qf
        },
        icons = {
            ['Error'] = { icon = utils.symbol_config.indicator_error, color = 'red' },
            ['Warning'] = { icon = utils.symbol_config.indicator_warning, color = 'yellow' },
            ['Information'] = { icon = utils.symbol_config.indicator_info, color = 'blue' },
            ['Hint'] = { icon = utils.symbol_config.indicator_hint, color = 'magenta' }
        }
    }
})

if vim.fn.isdirectory('.git') ~= 0 then
    utils.map("n", "<c-p>p", "<cmd>lua require('fzf-lua').git_files()<cr>")
    utils.map("n", "<c-p>P", "<cmd>lua require('fzf-lua').files()<cr>")
else
    utils.map("n", "<c-p>p", "<cmd>lua require('fzf-lua').files()<cr>")
    utils.map("n", "<c-p>P", "<cmd>lua require('fzf-lua').files()<cr>")
end

utils.map("n", "<c-p>b", "<cmd>lua require('fzf-lua').buffers()<cr>")
utils.map("n", "<c-p>z", "<cmd>lua require('fzf-lua').grep({search='TODO'})<cr>")
utils.map("n", "<c-p>F", "<cmd>lua require('fzf-lua').grep({search=''})<cr>")
utils.map("n", "<c-p>f", "<cmd>lua require('fzf-lua').live_grep_native()<cr>")

utils.map("n", "<leader>u", "<cmd>lua require('fzf-lua').lsp_references()<cr>")
utils.map("n", "<leader>U", "<cmd>lua require('fzf-lua').lsp_document_symbols()<cr>")
utils.map("n", "<leader>d", "<cmd>lua require('fzf-lua').lsp_definitions({sync = true, jump_to_single_result = true})<cr>")
utils.map("n", "<a-cr>", "<cmd>lua require('fzf-lua').lsp_code_actions()<cr>")

vim.cmd [[ command! Colors lua require('fzf-lua').colorschemes() ]]
