local utils = require('utils')
local misc = require('lib/misc')

vim.api.nvim_create_augroup('Misc', {clear = true})
vim.api.nvim_create_autocmd('TextYankPost', { group = 'Misc', pattern = '*', callback = function() vim.highlight.on_yank({on_visual = true}) end })
vim.api.nvim_create_autocmd('BufWritePre', { group = 'Misc', pattern = '*', callback = function() require('utils').strip_trailing_whitespaces() end })
vim.api.nvim_create_autocmd('FileType', { group = 'Misc', pattern = 'qf', callback = function()
    utils.map('n', '<c-v>', '<c-w><cr><c-w>L', {}, 0)
    utils.map('n', '<c-x>', '<c-w><cr><c-w>H', {}, 0)
end })

vim.api.nvim_create_augroup('UISetup', {clear = true})
vim.api.nvim_create_autocmd('BufEnter,ColorScheme', { group = 'UISetup', pattern = '*', callback = function()
    vim.highlight.create('Comment', {cterm = 'bold,italic', gui = 'bold,italic'}, false)
    vim.highlight.create('LineNr', {cterm = 'NONE', gui = 'NONE'}, false)
    vim.highlight.create('SignColumn', {cterm = 'NONE', gui = 'NONE'}, false)
end })

vim.api.nvim_create_augroup('TerminalSetup', {clear = true})
vim.api.nvim_create_autocmd('TermOpen', { group = 'TerminalSetup', pattern = '*', callback = function()
    vim.opt_local.filetype = 'terminal'
    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
end })

vim.cmd [[
    " TODO(vir): do this in lua
    augroup ConfigUpdate
        autocmd!
        autocmd BufWritePost ~/.config/nvim/init.lua source <afile>
        autocmd BufWritePost ~/.config/nvim/lua/*.lua source <afile>
    augroup end

    " NOTE(vir): now using nvim-notify
    function! AutoHighlightToggle()
      let @/ = ''
      if exists('#auto_highlight')
        autocmd! auto_highlight
        augroup! auto_highlight
        setl updatetime=5000

        " echo 'highlight current word: off'
        lua require('notify')('highlight current word: OFF', 'info', { render = 'minimal' })

        return 0
      else
        augroup auto_highlight
          autocmd!
          autocmd CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
        augroup end
        setl updatetime=500

        " echo 'highlight current word: on'
        lua require('notify')('highlight current word: ON', 'info', { render = 'minimal' })

        return 1
      endif
    endfunction
]]

-- TODO(vir): do this in lua
if misc.get_git_root() ~= nil then
    vim.api.nvim_add_user_command('OpenInGithub', function(_)
        vim.ui.select(misc.get_git_remotes(), { prompt = 'remote> ' },
                      function(remote) misc.open_repo_on_github(remote) end)
    end, {
        bang = true,
        nargs = 0,
        desc = 'Open chosen remote on GitHub, in the Browser'
    })
end

vim.api.nvim_add_user_command('SudoWrite', function()
    vim.cmd [[
        write !sudo -A tee > /dev/null %
        edit
    ]]
end, { bang = true, nargs = 0, desc = 'Sudo Write'})

