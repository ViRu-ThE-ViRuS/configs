local utils = require('utils')

return {
    {
        'famiu/bufdelete.nvim',
        init = function() utils.map("n", "<leader>q", function() require('bufdelete').bufdelete(0, true) end) end,
    },
    {
        'tpope/vim-fugitive',
        cmd = { 'G', 'Gread', 'GcLog' },
        init = function() utils.map("n", "<leader>gD", function() vim.cmd.G({ bang = true, args = { 'difftool' } }) end) end,
    },

    { 'tpope/vim-eunuch', cmd = { 'Delete', 'Rename', 'Chmod' } },
    { 'godlygeek/tabular', cmd = 'Tab', init = function() utils.map("v", "<leader>=", ":Tab /") end },
    { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' },
}

