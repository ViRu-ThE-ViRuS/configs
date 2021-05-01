-- Auto install packer.nvim if not exists
local install_path = vim.fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.api.nvim_command('!git clone https://github.com/wbthomason/packer.nvim '..install_path)
end
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'

    use 'scrooloose/nerdtree'
    use 'Xuyuanp/nerdtree-git-plugin'
    use 'majutsushi/tagbar'
    use 'pacha/vem-tabline'
    use 'airblade/vim-gitgutter'
    use 'tpope/vim-fugitive'

    use 'christoomey/vim-tmux-navigator'
    use 'tpope/vim-eunuch'
    use 'godlygeek/tabular'
    use 'airblade/vim-rooter'

    use 'neovim/nvim-lspconfig'
    use 'nvim-lua/completion-nvim'
    use 'steelsojka/completion-buffers'
    use 'nvim-lua/lsp-status.nvim'

    use { 'junegunn/fzf', run = function() vim.fn['fzf#install']() end }
    use 'junegunn/fzf.vim'
    use 'scrooloose/nerdcommenter'
    use 'jiangmiao/auto-pairs'

    use 'junegunn/gv.vim'
    use 'morhetz/gruvbox'
    use 'relastle/bluewery.vim'
    use 'flazz/vim-colorschemes'
end)

