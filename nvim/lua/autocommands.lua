local misc = require('lib/misc')

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

-- NOTE(vir): vista_kind ft remap, consider moving to ftplugin/vista_kind.lua
vim.api.nvim_create_autocmd('FileType', {
    group = 'Misc',
    pattern = {'vista_kind', 'NvimTree'},
    callback = function()
        require('utils').map('n', '<c-o>', '<cmd>wincmd p<cr>', {}, 0)
    end,
})

-- NOTE(vir): this only applies to colorschemes set manually
vim.api.nvim_create_augroup('UISetup', {clear = true})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = 'UISetup',
    pattern = '*',
    callback = function()
        vim.highlight.create('Comment', {cterm = 'bold,italic', gui = 'bold,italic'}, false)
        vim.highlight.create('LineNr', {cterm = 'NONE', gui = 'NONE'}, false)

        -- TODO(vir): do this in lua
        -- vim.highlight.create('SignColumn', {cterm = 'NONE', gui = 'NONE'}, false)
        vim.cmd [[ highlight! link SignColumn LineNr ]]
        vim.cmd [[ highlight! link VertSplit SignColumn ]]
    end
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

vim.cmd [[
    " TODO(vir): do this in lua
    augroup Configs
        autocmd!
        autocmd BufEnter ~/.config/kitty/kitty.conf setlocal filetype=bash
        autocmd BufWritePost ~/.config/nvim/init.lua source <afile>
        autocmd BufWritePost ~/.config/nvim/lua/*.lua source <afile>
    augroup end

    " NOTE(vir): now using nvim-notify
    function! AutoHighlightToggle()
      let @/ = ''
      if exists('#auto_highlight')
        autocmd! auto_highlight
        augroup! auto_highlight
        setlocal updatetime=2500

        " echo 'highlight current word: off'
        lua require('notify')('<cword> highlight deactivated', 'debug', {render='minimal'})

        return 0
      else
        augroup auto_highlight
          autocmd!
          autocmd CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
        augroup end
        setl updatetime=1000

        " echo 'highlight current word: on'
        lua require('notify')('<cword> highlight activated', 'info', {render='minimal'})

        return 1
      endif
    endfunction
]]

vim.defer_fn(function()

    -- setup OpenInGithub command, with vim.ui currently using fzf-lua
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

    vim.api.nvim_add_user_command('SudoWrite', function()
        vim.cmd [[
            write !sudo -A tee > /dev/null %
            edit
        ]]
    end, {bang = true, nargs = 0, desc = 'Sudo Write'})

end, 0)
