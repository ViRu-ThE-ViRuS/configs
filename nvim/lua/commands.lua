local misc = require('lib/misc')
local core = require('lib/core')
local colorscheme = require('colorscheme')
local utils = require('utils')
local plenary = require('plenary')

vim.api.nvim_create_augroup('UISetup', {clear = true})
vim.api.nvim_create_autocmd('ColorScheme', {
    group = 'UISetup',
    pattern = '*',
    callback = colorscheme.ui_overrides,
})

-- defer to improve responsiveness
vim.defer_fn(function()
    vim.api.nvim_create_augroup('Misc', {clear = true})
    vim.api.nvim_create_autocmd('TextYankPost', { group = 'Misc', pattern = '*', callback = function() vim.highlight.on_yank({on_visual = true}) end })
    vim.api.nvim_create_autocmd('BufWritePre', { group = 'Misc', pattern = '*', callback = misc.strip_trailing_whitespaces })
    -- vim.api.nvim_create_autocmd('BufReadPost', { group = 'Misc', pattern = '*', command = 'silent! normal `"' })

    -- NOTE(vir): plugin ft remaps: vista, nvimtree
    vim.api.nvim_create_autocmd('FileType', {
        group = 'Misc',
        pattern = {'vista_kind', 'vista', 'NvimTree'},
        callback = function()
            utils.map('n', '<c-o>', '<cmd>wincmd p<cr>', { buffer = 0 })
        end,
    })

    -- terminal setup
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

    -- config reloading
    vim.api.nvim_create_augroup('Configs', {clear = true})
    vim.api.nvim_create_autocmd('BufWritePost', { group = 'Configs', pattern = '.nvimrc.lua', command = 'source <afile>' })
    vim.api.nvim_create_autocmd('BufWritePost', {
        group = 'Configs',
        pattern = { core.get_homedir() .. '/.config/nvim/init.lua', core.get_homedir() .. '/.config/nvim/*/*.lua', },
        -- command = 'source $MYVIMRC',

        callback = function()
            local src_file = vim.fn.expand('<afile>')
            local rc_file = vim.fn.expand('$MYVIMRC')
            local rc_path = vim.fs.dirname(rc_file)
            local lua_path = plenary.Path.new(rc_path) .. '/lua/'

            -- only reload and refresh lsp when editing relevant files
            local skip_lsp_restart = string.find(src_file, 'lsp.*[setup/]*') == nil

            -- ret val is the table of all reloaded packages
            local to_reload = core.foreach(
                vim.split(vim.fn.globpath(rc_path, '**/**.lua'), "\n"),
                function(full_path)
                    local path_obj = plenary.Path.new(full_path)
                    local rel_path = vim.fn.fnamemodify(path_obj:make_relative(lua_path), ':r')

                    -- skip all files already unloaded
                    if not core.table_contains(package.loaded, rel_path) then return end

                    -- NOTE(vir): worth investigating
                    -- reloading treesj config too many times causes slow down for some reason
                    if string.find(rel_path, 'treesj') then return end
                    if skip_lsp_restart and string.find(rel_path, 'lsp.*[setup/]*') then return end

                    -- unload all lua files
                    package.loaded[rel_path] = nil
                    return rel_path
                end
            )

            -- stop all lsp servers if lsp configs have been updated
            if not skip_lsp_restart then
                vim.lsp.stop_client(vim.lsp.get_active_clients(), false)
            end

            -- load all files
            core.foreach(to_reload, require)

            -- NOTE(vir): hack to refresh sumneko lua
            -- without this, workspace symbols do not load, despite reloaded client
            -- causes on_attach of client to be called twice
            if not skip_lsp_restart then
                vim.defer_fn(function() vim.cmd [[ silent! e % ]] end, 150)
            end

            -- special cases
            if src_file == 'init.lua' then vim.cmd [[ source $MYVIMRC ]]  end
            if string.find(src_file, 'treesj') then vim.cmd [[ source <afile> ]]  end -- NOTE(vir): reload treesj only when updating it

            utils.notify('[CONFIG] reloaded', 'info', {render='minimal'}, true)
        end
    })

    -- custom commands
    utils.add_command("Commands", function()
        vim.ui.select(utils.workspace_config.commands.keys, { prompt = "command> " }, function(key)
            utils.workspace_config.commands.callbacks[key]()
        end)
    end, {
        bang = false,
        nargs = 0,
        desc = "Custom Commands",
    })

    -- open repository in github (after selecting remote)
    if misc.get_git_root() ~= nil then
        utils.add_command('OpenInGithub', function(_)
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
        }, true)
    end

    -- sudowrite to file
    utils.add_command('SudoWrite', function()
        vim.cmd [[
            write !sudo -A tee > /dev/null %
            edit
        ]]
    end, {bang = true, nargs = 0, desc = 'Sudo Write'}, true)

    -- messages in qflist
    utils.add_command('Messages', misc.show_messages, {
        bang = false,
        nargs = 0,
        desc = 'Show :messages in qflist',
    }, true)

    -- command output in qflist
    utils.add_command('Show', misc.show_command, {
        bang = false,
        nargs = '+',
        desc = 'Run Command and show output in qflist'
    })

    -- TODO(vir): do this in lua
    -- <cword> highlight toggle
    vim.cmd [[
        function! CWordHlToggle()
          let @/ = ''
          if exists('#auto_highlight')
            autocmd! auto_highlight
            augroup! auto_highlight
            setlocal updatetime=1000

            " echo 'highlight current word: off'
            lua require('utils').notify('<cword> highlight deactivated', 'debug', {render='minimal'}, true)

            return 0
          else
            augroup auto_highlight
              autocmd!
              autocmd CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
            augroup end
            setl updatetime=250

            " echo 'highlight current word: on'
            lua require('utils').notify('<cword> highlight activated', 'info', {render='minimal'}, true)

            return 1
          endif
        endfunction
    ]]

    -- generate tags
    utils.add_command('[MISC] Generate Tags', function()
        require('plenary').Job:new({
            command = 'ctags',
            args = { '-R', '--excmd=combine', '--fields=+K' },
            cwd = vim.loop.cwd(),
            on_start = function() utils.notify('generating tags', 'debug', { render = 'minimal' }, true) end,
            on_exit = function() utils.notify('tags generated', 'info', { render = 'minimal' }, true) end
        }):start()
    end, nil, true)

    -- toggles
    utils.add_command('Toggle CWord Highlights', 'if CWordHlToggle() | set hlsearch | endif', nil, true)
    utils.add_command('Toggle Thicc Seperators', misc.toggle_thicc_separators, nil, true)
    utils.add_command('Toggle Spellings', misc.toggle_spellings, nil, true)
    utils.add_command('Toggle Context WinBar', misc.toggle_context_winbar, nil, true)
end, 0)

