-- hello my name is viraat chandra and i love to program

-- load impatient first
require('impatient')
require('packer_compiled')

-- setup
require('colorscheme')          -- setup colorscheme
require('settings')             -- general setup
require('autocommands')         -- setup autocommands
require('plugins')              -- setup plugins
require('keymaps')              -- setup general keymaps
require('lsp')                  -- setup lsp
require('statusline')           -- setup custom statusline
require('terminal')             -- setup custom terminal behaviors

-- plugin configs
require('plug-config/fzf')
require('plug-config/tree')
require('plug-config/bufferline')

-- vim.defer_fn(function()
    require('plug-config/completion')
    require('plug-config/tmux')
    require('plug-config/gitsigns')
    require('plug-config/kommentary')
    require('plug-config/treesitter')
    require('plug-config/lspfuzzy')
    require('plug-config/pears')
    require('plug-config/signature')

    require('plug-config/vista')
    require('plug-config/tabular')
    -- require('plug-config/telescope')
-- end, 0)

-- notes --
-- so $VIMRUNTIME/syntax/hitest.vim : see colors
--
-- project setup:
--  .nvimrc             : nvim setup like venv
--  .rgignore           : ripgrep ignore
--  .clang-format       : clang-format config
--  .pep8               : autopep8 config
--  pyrightconfig.json  : pyright config

