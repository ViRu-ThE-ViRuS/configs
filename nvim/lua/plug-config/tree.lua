local utils = require('utils')
local tree_callback = require('nvim-tree/config').nvim_tree_callback

vim.g.nvim_tree_follow = 1
vim.g.nvim_tree_indent_markers = 1
vim.g.nvim_tree_add_trailing = 1
vim.g.nvim_tree_group_empty = 1
vim.g.nvim_tree_lsp_diagnostics = 1
vim.g.nvim_tree_auto_close = 0

vim.g.nvim_tree_window_picker_exclude = {
    filetype = { 'packer', 'qf', 'fugitive', 'Outline', 'vista' },
    buftype = { 'terminal' }
}

vim.g.nvim_tree_ignore = {
    '*.pyc',
    '.DS_Store',
    'node_modules',
    '__pycache__',
    'venv',
    '.git'
}

vim.g.nvim_tree_bindings = {
    { key = "<cr>"          , cb = tree_callback("edit") },
    { key = "o"             , cb = tree_callback("edit") },
    { key = "<2-leftmouse>" , cb = tree_callback("edit") },
    { key = "C"             , cb = tree_callback("cd") },
    { key = "<c-v>"         , cb = tree_callback("vsplit") },
    { key = "<c-x>"         , cb = tree_callback("split") },
    { key = "<bs>"          , cb = tree_callback("close_node") },
    { key = "I"             , cb = tree_callback("toggle_dotfiles") },
    { key = "R"             , cb = tree_callback("refresh") },
    { key = "<leader>n"     , cb = tree_callback("create") },
    { key = "<leader>d"     , cb = tree_callback("remove") },
    { key = "<leader>r"     , cb = tree_callback("full_rename") },
    { key = "[c"            , cb = tree_callback("prev_git_item") },
    { key = "]c"            , cb = tree_callback("next_git_item") },
    { key = "q"             , cb = tree_callback("close") },
}

vim.g.nvim_tree_show_icons = {
    git = 1,
    folders = 1,
    files = 0
}

vim.g.nvim_tree_icons = {
    -- folder = {
        -- default = '-',
        -- open = '-',
        -- empty = '-',
    -- },
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
        info = utils.symbol_config.sign_info,
        hint = utils.symbol_config.sign_hint,
        warning = utils.symbol_config.sign_warning,
        error = utils.symbol_config.sign_error
    }
}

utils.map('n', '<leader>j', '<cmd>NvimTreeToggle<cr>')
