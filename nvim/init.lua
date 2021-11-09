-- hello my name is viraat chandra and i love to program

-- load impatient first
require('impatient')
require('packer_compiled')

-- general setup setup
require('settings')             -- setup preferences
require('colorscheme')          -- setup colorscheme
require('plugins')              -- setup plugins
require('lsp')                  -- setup lsp
require('statusline')           -- setup statusline

-- plugin configs
require('plug-config/bufferline')
require('plug-config/pears')
require('plug-config/signature')

local async
async = vim.loop.new_async(vim.schedule_wrap(function()
    require('keymaps')              -- setup general keymaps
    require('autocommands')         -- setup autocommands
    require('terminal')             -- setup custom terminal behaviors

    require('plug-config/fzf')
    require('plug-config/tree')

    require('plug-config/gitsigns')
    require('plug-config/tmux')
    require('plug-config/kommentary')

    require('plug-config/tabular')
    require('plug-config/vista')

    async:close()
end))
async:send()

-- notes --
-- so $VIMRUNTIME/syntax/hitest.vim : see colors
--
-- project setup:
--  .nvimrc             : nvim setup like venv
--  .rgignore           : ripgrep ignore
--  .clang-format       : clang-format config
--  .pep8               : autopep8 config
--  pyrightconfig.json  : pyright config

