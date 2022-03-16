local fzf = require('fzf-lua')
local utils = require("utils")
local misc = require('lib/misc')
local actions = require("fzf-lua").actions
local plenary = require('plenary')

local default_rg_options = ' --hidden --follow --no-heading --smart-case --no-ignore -g "!{.DS_Store,.cache,venv,.git,.clangd,.ccls-cache,*.o,build,*.dSYM}"'

fzf.register_ui_select()
fzf.setup({
    winopts = {
        split = 'belowright new',
        fullscreen = false,
        preview = {
            default = 'bat',
            horizontal = 'right:50%',
            vertical = 'up:50%',
            scrollbar = false
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
    winopts_fn = function()
        return {
            preview = {
                layout = vim.api.nvim_win_get_width(0) <
                    utils.truncation_limit_s_terminal and 'vertical' or 'horizontal'
            }
        }
    end,
    fzf_opts = {['--layout'] = 'default'},
    fzf_colors = {
        ["fg"]       = { "fg", "CursorLine" },
        ["bg"]       = { "bg", "Normal" },
        ["hl"]       = { "fg", "Comment" },
        ["fg+"]      = { "fg", "Normal" },
        ["bg+"]      = { "bg", "CursorLine" },
        ["hl+"]      = { "fg", "Statement" },
        ["info"]     = { "fg", "PreProc" },
        ["prompt"]   = { "fg", "Conditional" },
        ["pointer"]  = { "fg", "Exception" },
        ["marker"]   = { "fg", "Keyword" },
        ["spinner"]  = { "fg", "Label" },
        ["header"]   = { "fg", "Comment" },
        ["gutter"]   = { "bg", "Normal" },
    },
    keymap = {
        fzf = {
            ['ctrl-a'] = 'toggle-all',
            ['ctrl-f'] = 'half-page-down',
            ['ctrl-b'] = 'half-page-up',
            ['ctrl-u'] = 'beginning-of-line',
            ['ctrl-o'] = 'end-of-line',
            ['ctrl-d'] = 'abort'
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
            ['ctrl-v'] = actions.buf_vsplit
        }
    },
    previewers = {
        bat = {
            cmd = "bat",
            args = "--style=numbers,changes --color always",
            theme = 'Coldark-Dark'
        }
    },
    buffers = {
        previewer = 'builtin',
        actions = {['ctrl-q'] = {actions.buf_del, actions.resume}}
    },
    files = {rg_opts = '--files' .. default_rg_options},
    grep = {
        rg_opts = "--column --color=always" .. default_rg_options,
        rg_glob = true,
        actions = {
            ['ctrl-q'] = misc.fzf_to_qf,
            ['ctrl-g'] = actions.grep_lgrep,
        },
    },
    tags = {
        previewer = 'bat',
        actions = {
            ['ctrl-q'] = misc.fzf_to_qf,
            ['ctrl-g'] = actions.grep_lgrep
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
    utils.map("n", "<c-p>p", fzf.git_files)
    utils.map("n", "<c-p>P", fzf.files)
else
    utils.map("n", "<c-p>p", fzf.files)
    utils.map("n", "<c-p>P", fzf.files)
end

utils.map("n", "<c-p>b", fzf.buffers)
utils.map("n", "<c-p>f", fzf.live_grep)
utils.map("n", "<c-p>z", function() fzf.grep({search = 'TODO'}) end)

utils.map("n", "<c-p>ss", fzf.grep_cword)
utils.map("n", "<c-p>sP", fzf.tags_grep_cword)
utils.map("n", "<c-p>sp", fzf.tags_live_grep)
utils.map("n", "<f10>", function()
    plenary.Job:new({
        command = 'ctags',
        args = {'-R', '--excmd=combine'},
        cwd = misc.get_cwd(),
        on_start = function() require('notify')('generating tags', 'debug', {render = 'minimal'}) end,
        on_exit = function() require('notify')('tags generated', 'info', {render = 'minimal'}) end
    }):start()
end)

-- NOTE(vir): present even in non-lsp files, consider moving to lsp setup code
utils.map("n", "<m-cr>", fzf.lsp_code_actions)
utils.map("n", "<leader>u", fzf.lsp_references)
utils.map("n", "<leader>U", fzf.lsp_document_symbols)
utils.map("n", "<leader>d", function() fzf.lsp_definitions({sync = true, jump_to_single_result = true}) end)

vim.api.nvim_add_user_command('Colors', fzf.colorschemes, {
    bang = false,
    nargs = 0,
    desc = 'FzfLua powered colorscheme picker'
})
