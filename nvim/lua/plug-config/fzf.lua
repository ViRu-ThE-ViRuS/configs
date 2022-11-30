local utils = require("utils")
local misc = require('lib/misc')
local fzf = require('fzf-lua')
local actions = fzf.actions

-- NOTE(vir):
-- using fzf-lua functionality in buffer setup (lsp)
-- this works because lsp is loaded on BufEnter event
-- fzf-lua is loaded VimEnter event

local default_rg_options = ' --hidden --follow --no-heading --smart-case --no-ignore -g "!{.DS_Store,.cache,venv,.git,.clangd,.ccls-cache,*.o,build,*.dSYM,tags,node_modules,Pods}"'

-- fzf.deregister_ui_select()
fzf.register_ui_select()

fzf.setup({
    winopts = {
        split = 'belowright new',
        fullscreen = false,
        preview = {
            -- default = 'bat',
            horizontal = 'right:50%',
            vertical = 'up:50%',
            scrollbar = false
        },
        on_create = function()
            vim.opt_local.buflisted = false
            vim.opt_local.bufhidden = 'wipe'

            utils.map('t', '<c-k>', '<up>', {}, 0)
            utils.map('t', '<c-j>', '<down>', {}, 0)
            utils.map('t', '<esc>', '<cmd>quit<cr>', {}, 0)
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
    fzf_opts = { ['--layout'] = 'default' },
    fzf_colors = {
        ["fg"]      = { "fg", "CursorLine" },
        ["bg"]      = { "bg", "Normal" },
        ["hl"]      = { "fg", "Comment" },
        ["fg+"]     = { "fg", "Normal" },
        ["bg+"]     = { "bg", "CursorLine" },
        ["hl+"]     = { "fg", "Statement" },
        ["info"]    = { "fg", "PreProc" },
        ["prompt"]  = { "fg", "Conditional" },
        ["pointer"] = { "fg", "Exception" },
        ["marker"]  = { "fg", "Keyword" },
        ["spinner"] = { "fg", "Label" },
        ["header"]  = { "fg", "Comment" },
        ["gutter"]  = { "bg", "Normal" },
    },
    keymap = {
        fzf = {
            ['ctrl-a'] = 'toggle-all',
            ['ctrl-f'] = 'half-page-down',
            ['ctrl-b'] = 'half-page-up',
            ['ctrl-u'] = 'beginning-of-line',
            ['ctrl-o'] = 'end-of-line',
            ['ctrl-d'] = 'abort',
            -- ['ctrl-i'] = 'clear-query'

            -- preview (bat)
            ['shift-down'] = 'preview-page-down',
            ['shift-up'] = 'preview-page-up'
        }
    },
    actions = {
        files = {
            ['default'] = actions.file_edit,
            ['ctrl-x'] = actions.file_split,
            ['ctrl-v'] = actions.file_vsplit,
            ['ctrl-t'] = actions.file_tabedit,
            ['ctrl-q'] = actions.file_sel_to_qf
        },
        buffers = {
            ['default'] = actions.buf_edit,
            ['ctrl-x'] = actions.buf_split,
            ['ctrl-v'] = actions.buf_vsplit,
            ['ctrl-t'] = actions.buf_tabedit,
            ['ctrl-q'] = actions.buf_sel_to_qf
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
        previewer = 'bat',
        actions = {
            ['ctrl-d'] = { actions.buf_del, actions.resume },
            ['ctrl-x'] = actions.buf_split,         -- disable default
            ['ctrl-q'] = false                      -- disable default
        }
    },
    files = { rg_opts = '--files' .. default_rg_options },
    blines = {
        previewer = 'bat',
        actions = { ['ctrl-q'] = actions.buf_sel_to_qf }
    },
    grep = {
        rg_glob = true,
        rg_opts = "--column --color=always" .. default_rg_options,
        actions = { ['ctrl-g'] = actions.grep_lgrep }
    },
    tags = {
        previewer = 'bat',
        actions = { ['ctrl-g'] = actions.grep_lgrep }
    },
    lsp = {
        continue_last_search = false,
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

utils.map("n", "<c-p>f", function() fzf.live_grep({ exec_empty_query = true }) end)
utils.map("n", "<c-p>F", function() fzf.live_grep({ continue_last_search = true }) end)
utils.map("n", "<c-p>b", fzf.buffers)
utils.map("n", "<c-p>ss", fzf.grep_cword)
utils.map("n", "<c-p>sl", fzf.blines)
utils.map("n", "<c-p>sz", function() fzf.grep({ search = 'TODO|NOTE', no_esc = true }) end)
utils.map("v", "<c-p>ss", fzf.grep_visual)

-- ctags interaction
-- independent of lsp
utils.map("n", "<c-p>sP", fzf.tags_grep_cword)
utils.map("n", "<c-p>sp", function() fzf.tags_live_grep({ exec_empty_query = true }) end)
utils.map("v", "<c-p>sp", fzf.tags_grep_visual)

utils.add_command('Colors', fzf.colorschemes, {
    bang = false,
    nargs = 0,
    desc = 'FzfLua powered colorscheme picker'
}, true)

