local fzf = require('fzf-lua')
local utils = require("utils")
local misc = require('lib/misc')
local actions = require("fzf-lua").actions
local plenary = require('plenary')

local default_rg_options = ' --hidden --follow --no-heading --smart-case --no-ignore -g "!{.DS_Store,.cache,venv,.git,.clangd,.ccls-cache,*.o,build,*.dSYM,tags}"'

-- NOTE(vir): now using nvim-notify
-- TODO(vir): figure out the bugs in harpoon
-- local function set_harpoons(lines)
--     if not lines then
--         notify('could not set harpoons', 'error',
--                { render = 'minimal' })
--         return
--     end

--     if #lines > 10 then
--         notify('trying to set too many harpoons: #' .. #lines, 'error',
--         { render = 'minimal' })
--         return
--     end

--     -- using harpoon
--     for _, line in ipairs(lines) do
--         require('harpoon.mark').add_file(line)
--     end

--     notify(string.format(#lines .. ' harpoons set'), 'info',
--     { render = 'minimal' })
-- end

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

            utils.map('t', '<c-k>', '<up>', {}, 0)
            utils.map('t', '<c-j>', '<down>', {}, 0)
            utils.map('t', '<esc>', '<cmd>quit<cr>', {}, 0)
            -- utils.map('t', '', '<c-i>', {}, 0)
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
            ['ctrl-d'] = 'abort',
            -- ['ctrl-i'] = 'clear-query'
        }
    },
    actions = {
        files = {
            ['default'] = actions.file_edit,
            ['ctrl-x'] = actions.file_split,
            ['ctrl-v'] = actions.file_vsplit,
            ['ctrl-q'] = utils.qf_populate,
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
        actions = {
            ['ctrl-d'] = {actions.buf_del, actions.resume},
            ['ctrl-x'] = actions.buf_split,
            ['ctrl-q'] = false
        }
    },
    files = { rg_opts = '--files' .. default_rg_options, },
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
            ['ctrl-g'] = actions.grep_lgrep,
        },
        -- fzf_opts = {
        --     ['--with-nth'] = '3,1,2',
        --     ['--nth'] = '3,1,..',
        -- },
    },
    lsp = {
        actions = { ['ctrl-q'] = misc.fzf_to_qf },
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

utils.map("n", "<c-p>f", function() fzf.live_grep({exec_empty_query=true}) end)
utils.map("n", "<c-p>b", fzf.buffers)
utils.map("n", "<c-p>sz", function() fzf.grep({search = 'TODO'}) end)
utils.map("n", "<c-p>ss", fzf.grep_cword)
utils.map("n", "<c-p>sl", fzf.blines)

-- ctags interaction
utils.map("n", "<c-p>sP", fzf.tags_grep_cword)
utils.map("n", "<c-p>sp", function() fzf.tags_live_grep({exec_empty_query=true}) end)

-- NOTE(vir): now using nvim-notify
utils.map("n", "<f10>", function()
    local notify = require('notify')

    plenary.Job:new({
        command = 'ctags',
        args = {'-R', '--excmd=combine'},
        cwd = misc.get_cwd(),
        on_start = function() notify('generating tags', 'debug', {render = 'minimal'}) end,
        on_exit = function() notify('tags generated', 'info', {render = 'minimal'}) end
    }):start()
end)

-- NOTE(vir): present even in non-lsp files, consider moving to lsp setup code
utils.map("n", "<m-cr>", fzf.lsp_code_actions)
utils.map("n", "<leader>us", fzf.lsp_references)
utils.map("n", "<leader>ud", fzf.lsp_document_symbols)
utils.map("n", "<leader>uw", fzf.lsp_live_workspace_symbols)
utils.map("n", "<leader>d", function() fzf.lsp_definitions({sync = true, jump_to_single_result = true}) end)

vim.api.nvim_add_user_command('Colors', fzf.colorschemes, {
    bang = false,
    nargs = 0,
    desc = 'FzfLua powered colorscheme picker'
})

