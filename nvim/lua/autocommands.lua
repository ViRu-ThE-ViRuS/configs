local misc = require('lib/misc')
local colorscheme = require('colorscheme')

vim.api.nvim_create_augroup('Misc', {clear = true})
vim.api.nvim_create_autocmd('TextYankPost', {
    group = 'Misc',
    pattern = '*',
    callback = function() vim.highlight.on_yank({on_visual = true}) end
})
vim.api.nvim_create_autocmd('BufWritePre', {
    group = 'Misc',
    pattern = '*',
    callback = misc.strip_trailing_whitespaces
})

-- NOTE(vir): plugin ft remaps: vista, nvimtree
vim.api.nvim_create_autocmd('FileType', {
    group = 'Misc',
    pattern = {'vista_kind', 'vista', 'NvimTree'},
    callback = function()
        require('utils').map('n', '<c-o>', '<cmd>wincmd p<cr>', {}, 0)
    end,
})

-- NOTE(vir): this only applies to colorschemes set manually
vim.api.nvim_create_augroup('UISetup', {clear = true})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = 'UISetup',
    pattern = '*',
    callback = colorscheme.setup_ui_overrides,
})

vim.api.nvim_create_augroup('TerminalSetup', {clear = true})
vim.api.nvim_create_autocmd('TermOpen', {
    group = 'TerminalSetup',
    pattern = '*',
    callback = function()
        vim.opt_local.filetype = 'terminal'
        vim.opt_local.number = false
        vim.opt_local.signcolumn = 'no'
    end
})

-- TODO(vir): do this in lua
vim.cmd [[
    augroup Configs
        autocmd!
        autocmd BufEnter ~/.config/kitty/kitty.conf setlocal filetype=bash
        autocmd BufWritePost ~/.config/nvim/init.lua source <afile>
        autocmd BufWritePost ~/.config/nvim/lua/*.lua source <afile>
    augroup end
]]

-- custom commands
vim.defer_fn(function()

    -- TODO(vir): do this in lua
    -- NOTE(vir): now using nvim-notify
    -- <cword> highlight toggle
    vim.cmd [[
        function! CWordHlToggle()
          let @/ = ''
          if exists('#auto_highlight')
            autocmd! auto_highlight
            augroup! auto_highlight
            setlocal updatetime=1000

            " echo 'highlight current word: off'
            lua require('notify')('<cword> highlight deactivated', 'debug', {render='minimal'})

            return 0
          else
            augroup auto_highlight
              autocmd!
              autocmd CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
            augroup end
            setl updatetime=250

            " echo 'highlight current word: on'
            lua require('notify')('<cword> highlight activated', 'info', {render='minimal'})

            return 1
          endif
        endfunction
    ]]

    -- open repository in github (after selecting remote)
    if misc.get_git_root() ~= nil then
        vim.api.nvim_add_user_command('OpenInGithub', function(_)
            local remotes = misc.get_git_remotes()

            if #remotes > 1 then
                vim.ui.select(remotes, {prompt = 'remote> '}, function(remote)
                    misc.open_repo_on_github(remote)
                end)
            else
                misc.open_repo_on_github(remotes[1])
            end

        end, {
            bang = true,
            nargs = 0,
            desc = 'Open chosen remote on GitHub, in the Browser'
        })
    end

    -- sudowrite to file
    vim.api.nvim_add_user_command('SudoWrite', function()
        vim.cmd [[
            write !sudo -A tee > /dev/null %
            edit
        ]]
    end, {bang = true, nargs = 0, desc = 'Sudo Write'})

    -- messages in qflist
    vim.api.nvim_add_user_command('Messages', misc.show_messages, {
        bang = false,
        nargs = 0,
        desc = 'Show :messages in qflist',
    })

end, 0)

