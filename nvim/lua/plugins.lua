-- auto install packer.nvim if not exists
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
  vim.cmd [[ packadd packer.nvim ]]
end

vim.cmd [[ command! Ps PackerSync ]]
return require('packer').startup({function()
    use 'wbthomason/packer.nvim'
    use 'nvim-lua/plenary.nvim'
    use 'nathom/filetype.nvim'
    use 'lewis6991/impatient.nvim'

    use { 'nvim-treesitter/nvim-treesitter', run = function() vim.cmd [[ TSUpdate ]] end }
    use 'kyazdani42/nvim-web-devicons'
    use 'kyazdani42/nvim-tree.lua'
    use 'akinsho/nvim-bufferline.lua'

    use 'lewis6991/gitsigns.nvim'
    use 'aserowy/tmux.nvim'
    use 'b3nj5m1n/kommentary'
    use 'steelsojka/pears.nvim'

    use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
    use 'junegunn/fzf.vim'

    use 'neovim/nvim-lspconfig'
    use 'onsails/lspkind-nvim'
    use 'ray-x/lsp_signature.nvim'
    use 'ojroques/nvim-lspfuzzy'

    use 'L3MON4D3/LuaSnip'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/cmp-cmdline'
    use 'hrsh7th/nvim-cmp'

    use { 'liuchengxu/vista.vim', cmd = 'Vista' }
    use { 'tpope/vim-eunuch', cmd = 'Delete' }
    use { 'godlygeek/tabular', cmd = 'Tab' }
    use { 'tpope/vim-fugitive', cmd = 'G' }

    use 'bluz71/vim-nightfly-guicolors'
    use 'bluz71/vim-moonfly-colors'
    use 'shaunsingh/moonlight.nvim'
    use 'sainnhe/gruvbox-material'
    use 'RRethy/nvim-base16'
    use 'sainnhe/everforest'
    use 'Mofiqul/vscode.nvim'
    use 'EdenEast/nightfox.nvim'
    use 'mrjones2014/lighthaus.nvim'
    use 'https://gitlab.com/protesilaos/tempus-themes-vim.git'

    use { 'tweekmonster/startuptime.vim', cmd = 'StartupTime' }
end, config = { compile_path = vim.fn.stdpath('config')..'/lua/packer_compiled.lua' }})
