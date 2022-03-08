local utils = require('utils')
local core = require('lib/core')

local function open_in_finder(handle) core.lua_system("open -R " .. handle.absolute_path) end

vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_show_icons = {git = 1, folders = 1, files = 0}

vim.g.nvim_tree_icons = {
    -- folder = {
    --     default = '-',
    --     open = '-',
    --     empty = '-',
    -- },
    default = '',
    git = {
        unstaged = '~',
        staged = '+',
        unmerged = '=',

        untracked = '*',
        deleted = 'x',
        ignored = '-'
        -- renamed   = '->'
    },
    lsp = {
        info = utils.symbol_config.sign_info,
        hint = utils.symbol_config.sign_hint,
        warning = utils.symbol_config.sign_warning,
        error = utils.symbol_config.sign_error
    }
}

require('nvim-tree').setup({
    update_focused_file = {enable = true, update_cwd = false},
    diagnostics = {enable = false},
    filters = {
        custom = {
            '*.pyc', '.DS_Store', 'node_modules', '__pycache__', 'venv', '.git',
            '*.dSYM'
        }
    },
    view = {
        mappings = {
            list = {
                {key = "<cr>", action = "edit"},
                {key = "<2-leftmouse>", action = "edit"},
                {key = "C", action = "cd"},
                {key = "<c-v>", action = "vsplit"},
                {key = "<c-x>", action = "split"},
                {key = "<bs>", action = "close_node"},
                {key = "I", action = "toggle_dotfiles"},
                {key = "R", action = "refresh"},
                {key = "<leader>n", action = "create"},
                {key = "<leader>d", action = "remove"},
                {key = "<leader>r", action = "full_rename"},
                {key = "[c", action = "prev_git_item"},
                {key = "]c", action = "next_git_item"},
                {key = "q", action = "close"},
                {key = "Y", action = "copy_absolute_path"},
                {key = ".", action = ""},
                {key = "OO", action = "open_in_finder", action_cb = open_in_finder},
            }
        }
    },
    git = {ignore = false},
    actions = {
        open_file = {
            window_pciker = {
                exclude = {
                    filetype = {'packer', 'qf', 'fugitive', 'Outline', 'vista', 'diagnostics'},
                    buftype = {'terminal', 'nofile', 'help'}
                }
            }
        }
    }
})

utils.map('n', '<leader>j', '<cmd>NvimTreeToggle<cr>')
