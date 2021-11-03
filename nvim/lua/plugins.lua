-- auto install packer.nvim if not exists
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[ packadd packer.nvim ]]
end

vim.cmd [[ command! Ps PackerSync ]]

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use 'tpope/vim-eunuch'
    use 'godlygeek/tabular'
    use 'liuchengxu/vista.vim'
    use 'tpope/vim-fugitive'

    use 'aserowy/tmux.nvim'
    use 'b3nj5m1n/kommentary'
    use 'steelsojka/pears.nvim'
    use 'akinsho/nvim-bufferline.lua'
    use 'kyazdani42/nvim-web-devicons'
    use 'kyazdani42/nvim-tree.lua'
    use { 'lewis6991/gitsigns.nvim', requires = 'nvim-lua/plenary.nvim' }

    use 'neovim/nvim-lspconfig'
    use 'L3MON4D3/LuaSnip'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'

    use 'onsails/lspkind-nvim'
    use 'ray-x/lsp_signature.nvim'
    use 'ojroques/nvim-lspfuzzy'
    use { 'nvim-treesitter/nvim-treesitter', run = function() vim.cmd [[ TSUpdate ]] end }

    use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
    use 'junegunn/fzf.vim'

    use 'bluz71/vim-nightfly-guicolors'
    use 'bluz71/vim-moonfly-colors'
    use 'shaunsingh/moonlight.nvim'
    use 'sainnhe/gruvbox-material'
    use 'RRethy/nvim-base16'
    use 'sainnhe/everforest'
    use 'Mofiqul/vscode.nvim'
    use 'EdenEast/nightfox.nvim'
    use 'https://gitlab.com/protesilaos/tempus-themes-vim.git'

    -- use 'dstein64/vim-startuptime'
    use 'tweekmonster/startuptime.vim'
end)

