-- auto install packer.nvim if not exists
local install_path = vim.fn.stdpath('data') .. '/site/pack/packer/opt/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
    vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
    vim.cmd [[ packadd packer.nvim ]]
end

require('utils').add_command('Ps', 'PackerSync', { bang = true, nargs = 0, desc = 'Packer Sync' })
return require('packer').startup({
    function()
        use 'nvim-lua/plenary.nvim'
        use 'lewis6991/impatient.nvim'
        use { 'wbthomason/packer.nvim', event = 'VimEnter' }

        use { 'kyazdani42/nvim-web-devicons', event = 'VimEnter' }
        use { 'rcarriga/nvim-notify', event = 'VimEnter', config = 'require("plug-config/notify")' }
        use { 'aserowy/tmux.nvim', event = 'VimEnter', config = 'require("plug-config/tmux")' }

        use { 'tpope/vim-eunuch', cmd = { 'Delete', 'Rename', 'Chmod' } }
        use { 'godlygeek/tabular', cmd = 'Tab', setup = function() require('utils').map("v", "<leader>=", ":Tab /") end }
        use {
            'tpope/vim-fugitive',
            cmd = { 'G', 'Gread', 'GcLog' },
            setup = function() require('utils').map("n", "<leader>gD", function() vim.cmd.G({ bang = true, args = { 'difftool' } }) end) end,
        }
        use {
            'liuchengxu/vista.vim',
            cmd = 'Vista',
            config = 'require("plug-config/vista")',
            setup = function() require('utils').map('n', '<leader>k', function() vim.cmd.Vista({ bang = true, args = { '!' } }) end) end
        }

        use { 'machakann/vim-sandwich', event = 'BufReadPost', config = 'require("plug-config/sandwich")' }
        use { 'b3nj5m1n/kommentary', event = 'BufReadPost', config = 'require("plug-config/kommentary")' }
        use { 'lewis6991/gitsigns.nvim', event = 'BufReadPost', config = 'require("plug-config/gitsigns")' }
        use { 'akinsho/nvim-bufferline.lua', event = 'BufReadPost', config = 'require("plug-config/bufferline")' }
        use {
            'famiu/bufdelete.nvim',
            module = 'bufdelete',
            setup = function() require('utils').map("n", "<leader>q", function() require('bufdelete').bufdelete(0, true) end) end,
        }

        use {
            'nvim-treesitter/nvim-treesitter',
            requires = {
                { 'nvim-treesitter/nvim-treesitter-textobjects', after = 'nvim-treesitter' },
                { 'RRethy/nvim-treesitter-textsubjects', after = 'nvim-treesitter' },
                { 'JoosepAlviste/nvim-ts-context-commentstring', after = 'nvim-treesitter' },
                { 'yioneko/nvim-yati', after = 'nvim-treesitter' },
                { 'andymass/vim-matchup', after = 'nvim-treesitter' },

                { 'Wansmer/treesj', after = 'nvim-treesitter', config = 'require("plug-config/treesj")' },
                { 'Dkendal/nvim-treeclimber', after = 'nvim-treesitter', config = 'require("plug-config/treeclimber")' },

                { 'nvim-treesitter/playground', after = 'nvim-treesitter' },
            },
            run = ':TSUpdate',
            event = 'VimEnter',
            config = 'require("plug-config/treesitter")'
        }

        use {
            'hrsh7th/nvim-cmp',
            requires = {
                { 'hrsh7th/cmp-nvim-lsp', module = 'cmp_nvim_lsp' },
                { 'onsails/lspkind-nvim', module = 'lspkind' },

                { 'L3MON4D3/LuaSnip', after = 'nvim-cmp' },
                { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
                { 'hrsh7th/cmp-path', after = 'nvim-cmp' },
                { 'lukas-reineke/cmp-rg', after = 'nvim-cmp' },
                { 'hrsh7th/cmp-buffer', after = 'nvim-cmp' },
                { 'hrsh7th/cmp-cmdline', after = 'nvim-cmp' },
            },
            event = 'BufReadPost',
            config = "require('plug-config/cmp')"
        }

        use {
            'neovim/nvim-lspconfig',
            requires = {
                { 'jose-elias-alvarez/null-ls.nvim', module = 'null-ls' },
                { 'ray-x/lsp_signature.nvim', module = 'lsp_signature' },
            },
            event = 'BufReadPost',
            config = 'require("lsp")'
        }

        use {
            'mfussenegger/nvim-dap',
            requires = {
                { 'rcarriga/nvim-dap-ui', module = 'dapui' },
                { 'theHamsta/nvim-dap-virtual-text', module = 'nvim-dap-virtual-text' },
            },
            ft = { 'c', 'cpp', 'rust', 'python' },
            config = 'require("plug-config/dap")'
        }

        use { 'kyazdani42/nvim-tree.lua', after = 'nvim-web-devicons', config = 'require("plug-config/tree")' }
        use { 'ibhagwan/fzf-lua', after = 'nvim-web-devicons', config = 'require("plug-config/fzf")' }
        use { 'sindrets/diffview.nvim', after = 'vim-fugitive', config = 'require("plug-config/diffview")' }
        use { 'windwp/nvim-autopairs', after = 'nvim-cmp', config = 'require("plug-config/autopairs")' }

        -- colorschemes
        use 'bluz71/vim-nightfly-guicolors'
        use 'EdenEast/nightfox.nvim'
        use 'sam4llis/nvim-tundra'
        use 'marko-cerovac/material.nvim'
        use 'bluz71/vim-moonfly-colors'
        use 'olivercederborg/poimandres.nvim'
        use 'sainnhe/gruvbox-material'
        use 'luisiacc/gruvbox-baby'
        use 'ellisonleao/gruvbox.nvim'
        use 'kvrohit/mellow.nvim'
        use 'B4mbus/oxocarbon-lua.nvim'
        use 'kvrohit/rasmus.nvim'
        use 'Mofiqul/adwaita.nvim'
        use 'sainnhe/everforest'
        use 'Mofiqul/vscode.nvim'
        use 'Yazeed1s/oh-lucy.nvim'
        use 'w3barsi/barstrata.nvim'
        use 'kvrohit/substrata.nvim'
        use 'tanvirtin/monokai.nvim'
        use 'thepogsupreme/mountain.nvim'
        use { 'catppuccin/nvim', as = 'cappuccin' }
        use { 'rose-pine/neovim', as = 'rose-pine' }
        use 'habamax/vim-habamax'
        use 'chiendo97/intellij.vim'
        use 'JaySandhu/xcode-vim'
        use 'protesilaos/tempus-themes-vim'

        use { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' }
    end,
    config = {
        compile_path = vim.fn.stdpath('config') .. '/lua/packer_compiled.lua',
        display = { prompt_border = 'single' }
    }
})
