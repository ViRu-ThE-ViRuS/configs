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
        use 'aserowy/tmux.nvim'

        use { 'godlygeek/tabular', cmd = 'Tab' }
        use { 'liuchengxu/vista.vim', cmd = 'Vista' }
        use { 'tpope/vim-eunuch', cmd = {'Delete', 'Rename'} }
        use { 'tpope/vim-fugitive', cmd = {'G', 'Gread'} }
        use { 'machakann/vim-sandwich', event = 'BufRead' }
        use { 'andymass/vim-matchup', after = 'nvim-treesitter' }

        use {
            'nvim-treesitter/nvim-treesitter',
            run = ':TSUpdate',
            event = 'BufRead',
            config = 'require("plug-config/treesitter")'
        }
        use { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' }

        use {
            'kyazdani42/nvim-tree.lua',
            requires = 'kyazdani42/nvim-web-devicons',
            event = 'VimEnter',
            config = 'require("plug-config/tree")'
        }

        use { 'sindrets/diffview.nvim', after = 'vim-fugitive', config = 'require("plug-config/diffview")' }
        use { 'windwp/nvim-autopairs', after = 'nvim-cmp', config = 'require("plug-config/autopairs")' }
        use { 'karb94/neoscroll.nvim', event = 'WinScrolled', config = 'require("plug-config/neoscroll")' }
        use { 'akinsho/nvim-bufferline.lua', event = 'VimEnter', config = 'require("plug-config/bufferline")' }
        use { 'famiu/bufdelete.nvim', event = 'VimEnter' }
        use { 'b3nj5m1n/kommentary', event = 'BufRead', config = 'require("plug-config/kommentary")' }
        use { 'lewis6991/gitsigns.nvim', event = 'BufRead', config = 'require("plug-config/gitsigns")' }

        use {
            'hrsh7th/nvim-cmp',
            requires = {
                {'L3MON4D3/LuaSnip', before = 'nvim-cmp'},
                {'onsails/lspkind-nvim', before = 'nvim-cmp'},
                {'hrsh7th/cmp-nvim-lsp', before = 'nvim-cmp'},
                {'hrsh7th/cmp-cmdline', after = 'nvim-cmp'},
                {'lukas-reineke/cmp-rg', after = 'nvim-cmp'},
                {'hrsh7th/cmp-path', after = 'nvim-cmp'},
                {'hrsh7th/cmp-buffer', after = 'nvim-cmp'}
            },
            event = 'BufRead',
            config = "require('plug-config/completion')"
        }

        use {
            'ibhagwan/fzf-lua',
            requires = 'kyazdani42/nvim-web-devicons',
            event = 'VimEnter',
            config = 'require("plug-config/fzf")'
        }

        use { 'neovim/nvim-lspconfig', requires = 'jose-elias-alvarez/null-ls.nvim' }
        use { 'ray-x/lsp_signature.nvim', event = 'BufRead', config = 'require("plug-config/signature")' }
        -- use { 'untitled-ai/jupyter_ascending.vim', ft='python', config="require('plug-config/ascending')" }
        use {
            'mfussenegger/nvim-dap',
            requires = 'rcarriga/nvim-dap-ui',
            event = 'BufRead',
            config = 'require("plug-config/dap")'
        }

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
        use 'ozkanonur/nimda.vim'
        use 'FrenzyExists/aquarium-vim'
        use 'https://gitlab.com/protesilaos/tempus-themes-vim.git'

        use {'tweekmonster/startuptime.vim', cmd = 'StartupTime'}
    end,
    config = { compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua' }
})

