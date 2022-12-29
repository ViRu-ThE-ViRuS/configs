return {
    'kyazdani42/nvim-tree.lua',
    cmd = 'NvimTreeToggle',
    init = function() require('utils').map('n', '<leader>j', '<cmd>NvimTreeToggle<cr>') end,

    config = {
        update_focused_file = { enable = true, update_cwd = false },
        diagnostics = { enable = false },
        filters = {
            custom = {
                '*.pyc', '.DS_Store', 'node_modules', '__pycache__', 'venv', '.git',
                '*.dSYM'
            }
        },
        view = {
            mappings = {
                custom_only = true,
                list = {
                    { key = "<cr>", action = "edit" },
                    { key = "<2-leftmouse>", action = "edit" },
                    { key = "<c-v>", action = "vsplit" },
                    { key = "<c-x>", action = "split" },
                    { key = "<bs>", action = "close_node" },
                    { key = "J", action = "parent_node" },
                    { key = "[c", action = "prev_git_item" },
                    { key = "]c", action = "next_git_item" },
                    { key = "I", action = "toggle_dotfiles" },
                    { key = "R", action = "refresh" },
                    { key = "C", action = "cd" },
                    { key = "q", action = "close" },
                    { key = "f", action = "live_filter" },
                    { key = "F", action = "clear_live_filter" },
                    { key = "Y", action = "copy_absolute_path" },
                    { key = "<leader>n", action = "create" },
                    { key = "<leader>d", action = "remove" },
                    { key = "<leader>r", action = "rename" },
                    { key = "<leader>Q", action = "<nop>" },
                    {
                        key = "OO",
                        action = "open_in_finder",
                        action_cb = function(handle) require("lib/core").lua_system("open -R " .. handle.absolute_path) end,
                    },
                }
            }
        },
        git = { ignore = false },
        renderer = {
            indent_markers = { enable = true },
            add_trailing = true,
            full_name = true,
            group_empty = true,
            icons = {
                show = { git = true, folder = true, file = false },
                glyphs = {
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
                        deleted   = 'x',
                        ignored   = '.',
                        renamed   = '>'
                    }
                }
            }
        },
        actions = {
            open_file = {
                window_picker = {
                    exclude = {
                        filetype = { 'packer', 'qf', 'fugitive', 'Outline', 'vista', 'diagnostics' },
                        buftype = { 'terminal', 'nofile', 'help' }
                    }
                }
            }
        }
    }
}
