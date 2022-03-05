-- auto install packer.nvim if not exists
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.api.nvim_command( '!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd [[ packadd packer.nvim ]]
end

vim.cmd [[ command! Ps PackerSync ]]
return require('packer').startup({
    function()
        use 'wbthomason/packer.nvim'
        use 'nvim-lua/plenary.nvim'
        use 'nathom/filetype.nvim'
        use 'lewis6991/impatient.nvim'

        use 'kyazdani42/nvim-web-devicons'
        use { 'rcarriga/nvim-notify', event = 'VimEnter', config = 'require("plug-config/notifications")'}
        -- use { 'karb94/neoscroll.nvim', event = 'VimEnter', config = 'require("plug-config/neoscroll")' }

        use { 'godlygeek/tabular', cmd = 'Tab' }
        use { 'liuchengxu/vista.vim', cmd = 'Vista' }
        use { 'tpope/vim-eunuch', cmd = {'Delete', 'Rename'} }
        use { 'tpope/vim-fugitive', cmd = {'G', 'Gread', 'GcLog'} }
        use { 'machakann/vim-sandwich', event = 'BufReadPost' }
        use { 'andymass/vim-matchup', after = 'nvim-treesitter' }

        use { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' }
        use {
            'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate',
            event = 'BufRead',
            config = 'require("plug-config/treesitter")'
        }

        use {
            'kyazdani42/nvim-tree.lua',
            event = 'VimEnter',
            config = 'require("plug-config/tree")'
        }

        use { 'famiu/bufdelete.nvim', event = 'BufReadPost' }
        use { 'b3nj5m1n/kommentary', event = 'BufReadPost', config = 'require("plug-config/kommentary")' }
        use { 'lewis6991/gitsigns.nvim', event = 'BufReadPost', config = 'require("plug-config/gitsigns")' }
        use { 'akinsho/nvim-bufferline.lua', event = 'BufReadPost', config = 'require("plug-config/bufferline")' }
        use { 'aserowy/tmux.nvim', event = 'VimEnter', config = 'require("plug-config/tmux")' }
        use { 'sindrets/diffview.nvim', after = 'vim-fugitive', config = 'require("plug-config/diffview")' }
        use { 'windwp/nvim-autopairs', after = 'nvim-cmp', config = 'require("plug-config/autopairs")' }

        use {
            'hrsh7th/nvim-cmp',
            requires = {
                {'hrsh7th/cmp-nvim-lsp', event = 'BufRead'},
                {'onsails/lspkind-nvim', event = 'BufRead'},
                {'L3MON4D3/LuaSnip', after = 'nvim-cmp'},
                {'hrsh7th/cmp-cmdline', after = 'nvim-cmp'},
                {'lukas-reineke/cmp-rg', after = 'nvim-cmp'},
                {'hrsh7th/cmp-path', after = 'nvim-cmp'},
                {'hrsh7th/cmp-buffer', after = 'nvim-cmp'}
            },
            after = {'cmp-nvim-lsp', 'lspkind-nvim'},
            event = 'BufRead',
            config = "require('plug-config/completion')"
        }

        use {
            'mfussenegger/nvim-dap',
            requires = {{'rcarriga/nvim-dap-ui', ft = {'c', 'cpp', 'python'}}},
            ft = {'c', 'cpp', 'python'},
            config = 'require("plug-config/dap")'
        }

        use {
            'ibhagwan/fzf-lua',
            event = 'VimEnter',
            config = 'require("plug-config/fzf")'
        }

        use {
            'neovim/nvim-lspconfig',
            requires = {
                {'jose-elias-alvarez/null-ls.nvim', event = 'BufRead'},
                {'ray-x/lsp_signature.nvim', event = 'BufRead'}
            },
            after = {'null-ls.nvim', 'lsp_signature.nvim'},
            event = 'BufRead',
            config = 'require("lsp")'
        }

        -- use {
        --     'untitled-ai/jupyter_ascending.vim',
        --     ft='python',
        --     config="require('plug-config/ascending')"
        -- }

        use 'RRethy/nvim-base16'
        use 'bluz71/vim-nightfly-guicolors'
        use 'bluz71/vim-moonfly-colors'
        use 'shaunsingh/moonlight.nvim'
        use 'sainnhe/gruvbox-material'
        use 'luisiacc/gruvbox-baby'
        use 'catppuccin/nvim'
        use 'sainnhe/everforest'
        use 'Mofiqul/vscode.nvim'
        use 'rose-pine/neovim'
        use 'fedepujol/nv-themes'
        use 'davidosomething/vim-colors-meh'
        use 'sts10/vim-pink-moon'
        use 'nanotech/jellybeans.vim'
        use 'embark-theme/vim'
        use 'thepogsupreme/mountain.nvim'
        use 'heraldofsolace/nisha-vim'
        use 'FrenzyExists/aquarium-vim'
        use 'habamax/vim-saturnite'
        use 'https://gitlab.com/protesilaos/tempus-themes-vim.git'

        use { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' }
    end,
    config = { compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua' }
})

