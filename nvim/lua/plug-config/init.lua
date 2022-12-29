local utils = require('utils')

-- plugin setup
return {
    'nvim-lua/plenary.nvim',
    'lewis6991/impatient.nvim',

    { 'kyazdani42/nvim-web-devicons', config = { default = true } },
    { 'tpope/vim-eunuch', cmd = { 'Delete', 'Rename', 'Chmod' } },

    {
        'godlygeek/tabular',
        cmd = 'Tab',
        init = function()
            utils.map("v", "<leader>=", ":Tab /")
        end,
    },

    {
        'tpope/vim-fugitive',
        cmd = { 'G', 'Gread', 'GcLog' },
        init = function()
            utils.map("n", "<leader>gD", function()
                vim.cmd.G({ bang = true, args = { 'difftool' } })
            end)
        end,
    },

    {
        'famiu/bufdelete.nvim',
        init = function()
            utils.map("n", "<leader>q", function()
                require('bufdelete').bufdelete(0, true)
            end)
        end,
    },

    -- {
    --     'neovim/nvim-lspconfig',
    --     dependencies = {
    --         { 'jose-elias-alvarez/null-ls.nvim' },
    --         { 'ray-x/lsp_signature.nvim' },
    --     },
    --     event = 'BufReadPost',
    --     config = 'require("lsp")'
    -- },

    -- {
    --     'mfussenegger/nvim-dap',
    --     dependencies = {
    --         { 'rcarriga/nvim-dap-ui' },
    --         { 'theHamsta/nvim-dap-virtual-text' },
    --     },
    --     ft = { 'c', 'cpp', 'rust', 'python' },
    --     config = 'require("plug-config/dap")'
    -- },

    -- {
    --     'liuchengxu/vista.vim',
    --     cmd = 'Vista',
    --     config = 'require("plug-config/vista")',
    --     init = function()
    --         require('utils').map('n', '<leader>k', function()
    --             vim.cmd.Vista({ bang = true, args = { '!' } })
    --         end)
    --     end,
    -- },

    -- colorschemes
    { 'bluz71/vim-nightfly-guicolors', lazy = false },
    { 'EdenEast/nightfox.nvim', lazy = false },
    { 'sam4llis/nvim-tundra', lazy = false },
    { 'marko-cerovac/material.nvim', lazy = false },
    { 'bluz71/vim-moonfly-colors', lazy = false },
    { 'olivercederborg/poimandres.nvim', lazy = false },
    { 'sainnhe/gruvbox-material', lazy = false },
    { 'luisiacc/gruvbox-baby', lazy = false },
    { 'ellisonleao/gruvbox.nvim', lazy = false },
    { 'kvrohit/mellow.nvim', lazy = false },
    { 'B4mbus/oxocarbon-lua.nvim', lazy = false },
    { 'kvrohit/rasmus.nvim', lazy = false },
    { 'Mofiqul/adwaita.nvim', lazy = false },
    { 'sainnhe/everforest', lazy = false },
    { 'Mofiqul/vscode.nvim', lazy = false },
    { 'Yazeed1s/oh-lucy.nvim', lazy = false },
    { 'w3barsi/barstrata.nvim', lazy = false },
    { 'kvrohit/substrata.nvim', lazy = false },
    { 'tanvirtin/monokai.nvim', lazy = false },
    { 'thepogsupreme/mountain.nvim', lazy = false },
    { 'catppuccin/nvim', lazy = false },
    { 'rose-pine/neovim', lazy = false },
    { 'habamax/vim-habamax', lazy = false },
    { 'chiendo97/intellij.vim', lazy = false },
    { 'arzg/vim-colors-xcode', lazy = false },
    { 'protesilaos/tempus-themes-vim', lazy = false },

    { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' },
}
