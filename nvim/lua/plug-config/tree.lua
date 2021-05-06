local utils = require('utils')
local tree_callback = require('nvim-tree/config').nvim_tree_callback

vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_lsp_diagnostics = 1
vim.g.nvim_tree_auto_close = 1

vim.g.nvim_tree_ignore = {
    '*.pyc',
    '.DS_Store',
    'node_modules',
    '__pycache__',
    'venv',
    '.git'
}

vim.g.nvim_tree_bindings = {
    ["<cr>"]          = tree_callback("edit"),
    ["o"]             = tree_callback("edit"),
    ["<2-leftmouse>"] = tree_callback("edit"),
    ["C"]             = tree_callback("cd"),
    ["<c-v>"]         = tree_callback("vsplit"),
    ["<c-x>"]         = tree_callback("split"),
    ["<bs>"]          = tree_callback("close_node"),
    ["I"]             = tree_callback("toggle_dotfiles"),
    ["R"]             = tree_callback("refresh"),
    ["<leader>n"]     = tree_callback("create"),
    ["<leader>d"]     = tree_callback("remove"),
    ["<leader>r"]     = tree_callback("full_rename"),
    ["[c"]            = tree_callback("prev_git_item"),
    ["]c"]            = tree_callback("next_git_item"),
    ["q"]             = tree_callback("close"),
}

vim.g.nvim_tree_icons = {
    folder = {
        default = '-',
        open = '-',
        empty = '-'
    },
    git = {
        unstaged  = '~',
        staged    = '+',
        unmerged  = '=',
        untracked = '*',
        deleted   = 'x',
        ignored   = '-',
        -- renamed   = '->'
    },
    lsp = {
        ['info']    = utils.symbol_config.sign_info,
        ['hint ']   = utils.symbol_config.sign_hint,
        ['warning'] = utils.symbol_config.sign_warning,
        ['error']   = utils.symbol_config.sign_error
    }
}

utils.map('n', '<leader>j', '<cmd>NvimTreeToggle<cr>')
utils.map('n', '<leader>1', '<cmd>NvimTreeFindFile<cr>')
