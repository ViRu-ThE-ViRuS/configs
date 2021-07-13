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
    use 'tpope/vim-fugitive'   -- TODO(vir): find alternative

    use 'aserowy/tmux.nvim'
    use 'b3nj5m1n/kommentary'
    use 'steelsojka/pears.nvim'
    use 'akinsho/nvim-bufferline.lua'
    use { 'lewis6991/gitsigns.nvim', requires = {'nvim-lua/plenary.nvim'} }
    use { 'kyazdani42/nvim-tree.lua', requires = {'kyazdani42/nvim-web-devicons'} }

    use 'neovim/nvim-lspconfig'
    use 'hrsh7th/nvim-compe'
    use 'onsails/lspkind-nvim'
    use 'ojroques/nvim-lspfuzzy'
    use { 'nvim-treesitter/nvim-treesitter', run = function() vim.cmd [[ TSUpdate ]] end }

    use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
    use 'junegunn/fzf.vim'
    -- use { 'nvim-telescope/telescope.nvim', requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}} }

    use 'bluz71/vim-nightfly-guicolors'
    use 'bluz71/vim-moonfly-colors'
    use 'shaunsingh/moonlight.nvim'
    use 'RRethy/nvim-base16'
    use 'sainnhe/everforest'
    use 'glepnir/zephyr-nvim'
    use 'Mofiqul/vscode.nvim'
    use 'sainnhe/gruvbox-material'

    use 'dstein64/vim-startuptime'
end)
