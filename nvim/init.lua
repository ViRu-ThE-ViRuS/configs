-- hello my name is viraat chandra and i love to program

-- load impatient first
require('impatient')
require('packer_compiled')

-- general setup setup
require('settings')    -- setup preferences
require('colorscheme') -- setup colorscheme
require('plugins')     -- setup plugins
require('lsp')         -- setup lsp
require('statusline')  -- setup statusline

-- NOTE(vir): cannot lazy load these
require('plug-config/bufferline')
require('plug-config/signature')

-- plugin configs
-- async: editor feels more responsive (defered execution)
local async
async = vim.loop.new_async(vim.schedule_wrap(function()
    require('keymaps')
    require('autocommands')

    -- instant load
    require('plug-config/fzf')
    require('plug-config/tree')
    require('plug-config/gitsigns')
    require('plug-config/tmux')

    -- viml plugins
    require('plug-config/tabular')
    require('plug-config/vista')

    -- debugging
    require('plug-config/dap')

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
--  .clang-tidy         : clang-tidy config
--  .pep8               : autopep8 config
--  pyrightconfig.json  : pyright config

