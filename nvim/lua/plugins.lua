-- auto install packer.nvim if not exists
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[ packadd packer.nvim ]]
end

vim.cmd [[ command! Ps PackerSync ]]

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use 'airblade/vim-rooter'  -- TODO(vir): check if still usefull
    use 'jiangmiao/auto-pairs' -- TODO(vir): update to a lua plugin
    use 'tpope/vim-fugitive'   -- TODO(vir): find alternative
    use 'preservim/tagbar'     -- TODO(vir): find alternative
    use 'christoomey/vim-tmux-navigator'
    use 'tpope/vim-eunuch'
    use 'godlygeek/tabular'

    use 'b3nj5m1n/kommentary'
    use 'akinsho/nvim-bufferline.lua'
    use { 'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'} }
    use { 'kyazdani42/nvim-tree.lua', requires = {{'kyazdani42/nvim-web-devicons'}} }

    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-compe'
    use 'onsails/lspkind-nvim'
    use { 'nvim-treesitter/nvim-treesitter', run = function() vim.cmd [[ TSUpdate ]] end }

    use 'junegunn/fzf.vim'
    use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
    --use { 'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} }

    use 'morhetz/gruvbox'
    use 'relastle/bluewery.vim'
    use 'flazz/vim-colorschemes'
    use 'shaunsingh/moonlight.nvim'
    use 'folke/tokyonight.nvim'
    use 'bluz71/vim-moonfly-colors'
    use 'bluz71/vim-nightfly-guicolors'

    -- use 'tweekmonster/startuptime.vim'
end)

