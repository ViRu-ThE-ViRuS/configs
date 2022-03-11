local utils = require("utils")
local misc = require('lib/misc')
local actions = require("fzf-lua").actions

local default_rg_options = ' --hidden --follow --no-heading --smart-case --no-ignore -g "!{.DS_Store,.cache,venv,.git,.clangd,.ccls-cache,*.o,build,*.dSYM}"'

require("fzf-lua").setup({
    winopts = {
        split = 'belowright new',
        fullscreen = false,
        preview = {
            default = 'bat',
            horizontal = 'right:50%',
            vertical = 'up:50%',
        },
        on_create = function()
            vim.opt_local.buflisted = false
            vim.opt_local.bufhidden = 'wipe'
            -- vim.opt_local.signcolumn = 'no'
            -- vim.opt_local.statusline = require('statusline').StatusLine('FZF')

            utils.map('n', '<c-d>', '<cmd>quit<cr>', {}, 0)
            utils.map('t', '<c-k>', '<up>', {}, 0)
            utils.map('t', '<c-j>', '<down>', {}, 0)
        end,
    },
    winopts_fn = function() return {preview = {layout = vim.api.nvim_win_get_width(0) < utils.truncation_limit_s_terminal and 'vertical' or 'horizontal'}} end,
    fzf_opts = { ['--layout'] = 'default' },
    keymap = {
        fzf = {
            ['ctrl-a'] = 'toggle-all',
            ['ctrl-f'] = 'half-page-down',
            ['ctrl-b'] = 'half-page-up',
            ['ctrl-u'] = 'beginning-of-line',
            ['ctrl-o'] = 'end-of-line',
            ['ctrl-d'] = 'abort',
        }
    },
    actions = {
        files = {
            ['default'] = actions.file_edit,
            ['ctrl-x'] = actions.file_split,
            ['ctrl-v'] = actions.file_vsplit,
            ['ctrl-q'] = utils.qf_populate
        },
        buffers = {
            ['default'] = actions.buf_edit,
            ['ctrl-x'] = actions.buf_split,
            ['ctrl-v'] = actions.buf_vsplit,
        }
    },
    previewers = {
        bat = {
            cmd = "bat",
            args = "--style=numbers,changes --color always",
            theme = 'Coldark-Dark',
        }
    },
    buffers = {
        previewer = 'builtin',
        actions = { ['ctrl-q'] = { actions.buf_del, actions.resume } }
    },
    files = {
        rg_opts = '--files' .. default_rg_options,
    },
    grep = {
        -- rg_opts = "--column --color=always" .. default_rg_options,
        actions = {
          ['ctrl-q'] = misc.fzf_to_qf,
          ['ctrl-g'] = actions.grep_lgrep,
          ['ctrl-l'] = false
        }
    },
    tags = {
        actions = {
          ['ctrl-q'] = utils.qf_populate,
          ['ctrl-g'] = actions.grep_lgrep,
          ['ctrl-l'] = false
        }
    },
    lsp = {
        actions = { ['ctrl-q'] = misc.fzf_to_qf },
        icons = {
            ['Error'] = { icon = utils.symbol_config.indicator_error, color = 'red' },
            ['Warning'] = { icon = utils.symbol_config.indicator_warning, color = 'yellow' },
            ['Information'] = { icon = utils.symbol_config.indicator_info, color = 'blue' },
            ['Hint'] = { icon = utils.symbol_config.indicator_hint, color = 'magenta' }
        }
    }
})

if misc.get_git_root() ~= nil then
    utils.map("n", "<c-p>p", "<cmd>lua require('fzf-lua').git_files()<cr>")
    utils.map("n", "<c-p>P", "<cmd>lua require('fzf-lua').files()<cr>")
else
    utils.map("n", "<c-p>p", "<cmd>lua require('fzf-lua').files()<cr>")
    utils.map("n", "<c-p>P", "<cmd>lua require('fzf-lua').files()<cr>")
end

utils.map("n", "<c-p>b", "<cmd>lua require('fzf-lua').buffers()<cr>")
utils.map("n", "<c-p>f", "<cmd>lua require('fzf-lua').live_grep_native()<cr>")
utils.map("n", "<c-p>z", "<cmd>lua require('fzf-lua').grep({search='TODO'})<cr>")

utils.map("n", "<c-p>sg", "<cmd>lua require('fzf-lua').live_grep_glob()<cr>")
utils.map("n", "<c-p>ss", "<cmd>lua require('fzf-lua').grep_cword()<cr>")
-- utils.map("n", "<c-p>sp", "<cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<cr>")

utils.map("n", "<c-p>sP", "<cmd>lua require('fzf-lua').tags_grep_cword({previewer='bat'})<cr>")
utils.map("n", "<c-p>sp", "<cmd>lua require('fzf-lua').tags({previewer='bat'})<cr>")
utils.map("n", "<f10>", "<cmd>!ctags -R<cr>")

-- NOTE(vir): present even in non-lsp files, consider moving to lsp setup code
utils.map("n", "<leader>u", "<cmd>lua require('fzf-lua').lsp_references()<cr>")
utils.map("n", "<leader>U", "<cmd>lua require('fzf-lua').lsp_document_symbols()<cr>")
utils.map("n", "<leader>d", "<cmd>lua require('fzf-lua').lsp_definitions({sync=true, jump_to_single_result=true})<cr>")
utils.map("n", "<m-cr>", "<cmd>lua require('fzf-lua').lsp_code_actions()<cr>")

vim.cmd [[ command! Colors lua require('fzf-lua').colorschemes() ]]

