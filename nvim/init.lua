-- hello my name is viraat chandra and i love to program

-- setup
require('autocommands')         -- setup autocommands
require('plugins')              -- setup plugins
require('settings')             -- general setup
require('keymaps')              -- setup general keymaps
require('lsp')                  -- setup lsp
require('statusline')           -- setup custom statusline

-- plugin configs
require('plug-config/completion')
require('plug-config/tree')
require('plug-config/bufferline')
require('plug-config/gitsigns')
require('plug-config/kommentary')
require('plug-config/treesitter')
require('plug-config/lspkind')

require('plug-config/tagbar')
require('plug-config/tabular')
require('plug-config/autopairs')
require('plug-config/fzf')
-- require('plug-config/telescope')

-- notes ---
-- see colors: so $VIMRUNTIME/syntax/hitest.vim
--
-- project setup:
--  .nvimrc       : nvim setup like venv
--  .lsconf.json  : language server config
--  .rgignore     : ripgrep ignore
--  .clang-format : clang-format config
--  setup.cfg     : pycodestyle config
