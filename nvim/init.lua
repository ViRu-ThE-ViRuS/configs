-- hello my name is viraat chandra and i love to program
-- impatient.nvim
require('impatient')
require('packer_compiled')

require('settings')
require('colorscheme')
require('lsp')
require('statusline')

local async
async = vim.loop.new_async(vim.schedule_wrap(function()
    -- plugin configs async: editor feels more responsive (defered execution)
    require('keymaps')
    require('autocommands')
    require('plugins')

    -- NOTE(vir): load this here, to keep plugins.lua clean
    require('plug-config/vista')

    async:close()
end))
async:send()

-- notes --
-- so $VIMRUNTIME/syntax/hitest.vim : see colors
--
-- project setup:
--  .clang-format       : clang-format config
--  .clang-tidy         : clang-tidy config
--  .flake8               : autopep8 config
--  pyrightconfig.json  : pyright config

