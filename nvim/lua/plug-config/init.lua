local utils = require('utils')

return {
    'nvim-lua/plenary.nvim',
    'kyazdani42/nvim-web-devicons',

    {
        'williamboman/mason-lspconfig.nvim',
        'jayp0521/mason-null-ls.nvim',
        'jay-babu/mason-nvim-dap.nvim',
        'williamboman/mason.nvim',
    },

    {
        'neovim/nvim-lspconfig',
        dependencies = { 'jose-elias-alvarez/null-ls.nvim', 'ray-x/lsp_signature.nvim' },
        event = 'BufReadPost',
        config = function() require("lsp") end,
    },

    {
        'tpope/vim-fugitive',
        cmd = { 'G', 'Gread', 'GcLog' },
        init = function() utils.map("n", "<leader>gD", function() vim.cmd.G({ bang = true, args = { 'difftool' } }) end) end,
    },

    {
        'famiu/bufdelete.nvim',
        init = function() utils.map("n", "<leader>q", function() require('bufdelete').bufdelete(0, true) end) end,
    },

    { 'tpope/vim-eunuch', cmd = { 'Delete', 'Rename', 'Chmod' } },
    { 'godlygeek/tabular', cmd = 'Tab', init = function() utils.map("v", "<leader>=", ":Tab /") end },

    -- colorschemes
    'bluz71/vim-nightfly-guicolors',
    'EdenEast/nightfox.nvim',
    'sam4llis/nvim-tundra',
    'marko-cerovac/material.nvim',
    'bluz71/vim-moonfly-colors',
    'olivercederborg/poimandres.nvim',
    'sainnhe/gruvbox-material',
    'luisiacc/gruvbox-baby',
    'ellisonleao/gruvbox.nvim',
    'kvrohit/mellow.nvim',
    'B4mbus/oxocarbon-lua.nvim',
    'kvrohit/rasmus.nvim',
    'Mofiqul/adwaita.nvim',
    'sainnhe/everforest',
    'Mofiqul/vscode.nvim',
    'Yazeed1s/oh-lucy.nvim',
    'w3barsi/barstrata.nvim',
    'kvrohit/substrata.nvim',
    'tanvirtin/monokai.nvim',
    'thepogsupreme/mountain.nvim',
    'catppuccin/nvim',
    'rose-pine/neovim',
    'habamax/vim-habamax',
    'chiendo97/intellij.vim',
    'arzg/vim-colors-xcode',
    'protesilaos/tempus-themes-vim',

    { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' },
}
