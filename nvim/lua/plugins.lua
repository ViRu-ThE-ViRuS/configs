-- auto install packer.nvim if not exists
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[packadd packer.nvim]]
end

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use { 'kyazdani42/nvim-tree.lua', requires = {{'kyazdani42/nvim-web-devicons'}} }
    use 'majutsushi/tagbar'
    use 'pacha/vem-tabline'
    use 'tpope/vim-fugitive'
    use { 'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'} }

    use 'christoomey/vim-tmux-navigator'
    use 'tpope/vim-eunuch'
    use 'godlygeek/tabular'
    use 'airblade/vim-rooter'

    use { 'nvim-treesitter/nvim-treesitter', run = function() vim.api.nvim_exec('TSUpdate', 0) end }
    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-compe'
    use 'onsails/lspkind-nvim'

    --use { 'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} }
    use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
    use 'junegunn/fzf.vim'

    use 'scrooloose/nerdcommenter'
    use 'jiangmiao/auto-pairs'

    use 'morhetz/gruvbox'
    use 'relastle/bluewery.vim'
    use 'shaunsingh/moonlight.nvim'
    use 'flazz/vim-colorschemes'
end)

