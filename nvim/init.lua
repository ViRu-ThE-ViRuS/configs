-- hello my name is viraat chandra and i love to program

-- setup
require('settings')             -- general setup
require('autocommands')         -- setup autocommands
require('plugins')              -- setup plugins
require('keymaps')              -- setup general keymaps
require('lsp')                  -- setup lsp
require('statusline')           -- setup custom statusline

-- plugin configs
require('plug-config/tree')

-- NOTE(vir): defer some configs to decrease startup time
vim.defer_fn(function()
    require('plug-config/tmux')
    require('plug-config/completion')
    require('plug-config/bufferline')
    require('plug-config/gitsigns')
    require('plug-config/kommentary')
    require('plug-config/treesitter')
    require('plug-config/lspkind')
    require('plug-config/neoscroll')
    require('plug-config/lspfuzzy')
    require('plug-config/pears')

    require('plug-config/vista')
    require('plug-config/tabular')
    require('plug-config/fzf')
    -- require('plug-config/telescope')
end, 0)

-- notes ---
-- see colors: so $VIMRUNTIME/syntax/hitest.vim
--
-- project setup:
--  .nvimrc       : nvim setup like venv
--  .lsconf.json  : language server config
--  .rgignore     : ripgrep ignore
--  .clang-format : clang-format config
--  setup.cfg     : pycodestyle config

