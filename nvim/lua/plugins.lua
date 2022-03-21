-- auto install packer.nvim if not exists
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.api.nvim_command( '!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd [[ packadd packer.nvim ]]
end

vim.api.nvim_add_user_command('Ps', 'PackerSync', { bang = true, nargs = 0, desc = 'Packer Sync' })
return require('packer').startup({
    function()
        use 'nvim-lua/plenary.nvim'
        use 'lewis6991/impatient.nvim'
        use { 'wbthomason/packer.nvim', event = 'VimEnter' }

        use { 'kyazdani42/nvim-web-devicons', event = 'VimEnter' }
        use { 'rcarriga/nvim-notify', event = 'VimEnter', config = 'require("plug-config/notifications")' }

        use { 'godlygeek/tabular', cmd = 'Tab' }
        use { 'liuchengxu/vista.vim', cmd = 'Vista' }
        use { 'tpope/vim-eunuch', cmd = {'Delete', 'Rename', 'Chmod'} }
        use { 'tpope/vim-fugitive', cmd = {'G', 'Gread', 'GcLog'} }
        use { 'AndrewRadev/splitjoin.vim', event = 'BufReadPost' }

        use {
            'nvim-treesitter/nvim-treesitter',
            requires = {
                {'machakann/vim-sandwich', event = 'BufRead'},
                {'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter'},
                {'andymass/vim-matchup', after = 'nvim-treesitter'},
            },
            run = ':TSUpdate',
            after = 'vim-sandwich',
            config = 'require("plug-config/treesitter")'
        }

        use { 'famiu/bufdelete.nvim', event = 'BufReadPost' }
        use { 'b3nj5m1n/kommentary', event = 'BufReadPost', config = 'require("plug-config/kommentary")' }
        use { 'lewis6991/gitsigns.nvim', event = 'BufReadPost', config = 'require("plug-config/gitsigns")' }
        use { 'aserowy/tmux.nvim', event = 'VimEnter', config = 'require("plug-config/tmux")' }

        use { 'sindrets/diffview.nvim', after = 'vim-fugitive', config = 'require("plug-config/diffview")' }
        use { 'windwp/nvim-autopairs', after = 'nvim-cmp', config = 'require("plug-config/autopairs")' }
        use { 'kyazdani42/nvim-tree.lua', after = 'nvim-web-devicons', config = 'require("plug-config/tree")' }
        use { 'akinsho/nvim-bufferline.lua', after = 'nvim-web-devicons', config = 'require("plug-config/bufferline")' }
        use { 'ibhagwan/fzf-lua', after = 'nvim-web-devicons', config = 'require("plug-config/fzf")' }

        use {
            'hrsh7th/nvim-cmp',
            requires = {
                {'hrsh7th/cmp-nvim-lsp', event = 'BufRead'},
                {'onsails/lspkind-nvim', event = 'BufRead'},
                {'L3MON4D3/LuaSnip', after = 'nvim-cmp'},
                {'lukas-reineke/cmp-rg', after = 'nvim-cmp'},
                {'hrsh7th/cmp-buffer', after = 'nvim-cmp'},
                {'hrsh7th/cmp-path', after = 'nvim-cmp'},
                {'hrsh7th/cmp-cmdline', after = 'nvim-cmp'}
            },
            after = {'cmp-nvim-lsp', 'lspkind-nvim'},
            config = "require('plug-config/completion')"
        }

        use {
            'neovim/nvim-lspconfig',
            requires = {
                {'jose-elias-alvarez/null-ls.nvim', event = 'BufRead'},
                {'ray-x/lsp_signature.nvim', event = 'BufRead'}
            },
            after = {'null-ls.nvim', 'lsp_signature.nvim'},
            config = 'require("lsp")'
        }

        use {
            'mfussenegger/nvim-dap',
            requires = {{'rcarriga/nvim-dap-ui', ft = {'c', 'cpp', 'python'}}},
            ft = {'c', 'cpp', 'python'},
            config = 'require("plug-config/dap")'
        }

        -- use {
        --     'ThePrimeagen/harpoon',
        --     event = 'VimEnter',
        --     config = 'require("plug-config/harpoon")'
        -- }

        -- use {
        --     'untitled-ai/jupyter_ascending.vim',
        --     ft='python',
        --     config="require('plug-config/ascending')"
        -- }

        use 'RRethy/nvim-base16'
        use 'bluz71/vim-nightfly-guicolors'
        use 'EdenEast/nightfox.nvim'
        use 'rebelot/kanagawa.nvim'
        use 'marko-cerovac/material.nvim'
        use 'bluz71/vim-moonfly-colors'
        use 'sainnhe/gruvbox-material'
        use 'luisiacc/gruvbox-baby'
        use 'catppuccin/nvim'
        use 'sainnhe/everforest'
        use 'Mofiqul/vscode.nvim'
        use 'rose-pine/neovim'
        use 'kvrohit/substrata.nvim'
        use 'tanvirtin/monokai.nvim'
        use 'nanotech/jellybeans.vim'
        use 'thepogsupreme/mountain.nvim'
        use 'habamax/vim-saturnite'
        use 'https://gitlab.com/protesilaos/tempus-themes-vim.git'

        use { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' }
    end,
    config = { compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua' }
})

