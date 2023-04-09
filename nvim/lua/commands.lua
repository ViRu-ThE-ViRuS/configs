local misc = require('lib/misc')
local core = require('lib/core')

local colorscheme = require('colorscheme')
local utils = require('utils')

local plenary = require('plenary')

--- autocommands

-- ui setup
vim.api.nvim_create_augroup('UISetup', { clear = true })
vim.api.nvim_create_autocmd('ColorScheme', {
  group = 'UISetup',
  pattern = '*',
  callback = colorscheme.ui_overrides,
})

vim.api.nvim_create_augroup('Misc', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  group = 'Misc',
  pattern = '*',
  callback = core.partial(vim.highlight.on_yank, { on_visual = true })
})
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'Misc',
  pattern = '*',
  callback = misc.strip_trailing_whitespaces,
})
-- return to last cursor position when new buf is opened
-- vim.api.nvim_create_autocmd('BufReadPost', {
--   group = 'Misc',
--   pattern = '*',
--   command = 'silent! normal `"',
-- })

-- terminal setup
vim.api.nvim_create_augroup('TerminalSetup', { clear = true })
vim.api.nvim_create_autocmd('TermOpen', {
  group = 'TerminalSetup',
  callback = function()
    vim.opt_local.filetype = 'terminal'
    vim.opt_local.number = false
    vim.opt_local.signcolumn = 'no'
    vim.opt_local.statuscolumn = ''
  end
})

-- config reloading
vim.api.nvim_create_augroup('Configs', { clear = true })
vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'Configs',
  pattern = '.nvimrc.lua',
  callback = function()
    -- reload local config
    -- vim.cmd('source')
    require('lib/local_session').load_local_session(true)

    utils.notify('.nvimrc.lua', 'info', {
      title = '[CONFIG] session reloaded',
      render = 'compact',
    })
  end
})
vim.api.nvim_create_autocmd('BufWritePost', {
  group = 'Configs',
  pattern = {
    core.get_homedir() .. '/.config/nvim/init.lua',
    core.get_homedir() .. '/.config/nvim/*/*.lua',
  },
  callback = function()
    local src_file = vim.fn.expand('<afile>')
    local rc_file = vim.fn.expand('$MYVIMRC')
    local rc_path = vim.fs.dirname(rc_file)
    local lua_path = plenary.Path.new(rc_path) .. '/lua/'

    -- collect all config files to reload
    local to_reload = core.foreach(
      vim.split(vim.fn.globpath(rc_path, '**/**.lua'), "\n"),
      function(_, full_path)
        -- will only consider files within lua/
        local path_obj = plenary.Path.new(full_path)
        local rel_path = vim.fn.fnamemodify(path_obj:make_relative(lua_path), ':r')

        -- NOTE(vir): skip files
        --  1. not already loaded
        --  2. lazy.nvim config cannot be reloaded
        --  3. lazy.nvim plugin specs cannot be reloaded
        if not core.table_contains(package.loaded, rel_path) then return end
        if string.find(rel_path, 'plugins') then return end
        if string.find(rel_path, 'plug-config/') then return end

        -- unload mod
        package.loaded[rel_path] = nil
        return rel_path
      end
    )

    -- stop all servers before reloading
    vim.lsp.stop_client(vim.lsp.get_active_clients(), false)

    -- TODO(vir): get this working
    -- source current file, source config file
    -- reload all unloaded modules

    core.foreach(
      to_reload,
      function(_, mod)
        require(mod)
        -- dofile('lua/' .. mod .. '.lua')
      end
    )

    vim.cmd [[ source ]]
    vim.cmd.doautocmd('User VeryLazy')

    utils.notify(src_file, 'info', {
      title = '[CONFIG] reloaded from',
      render = 'compact',
    })
  end
})

-- NOTE(vir): Commands cmd setup in fzf-lua init
--- custom commands

-- open repository in github (after selecting remote)
if misc.get_git_root() ~= nil then
  utils.add_command('OpenInGithub', function(_)
    local remotes = misc.get_git_remotes()

    if #remotes > 1 then
      vim.ui.select(remotes, { prompt = 'open remote> ', kind = 'plain_text' }, function(remote)
        misc.open_repo_on_github(remote)
      end)
    else
      misc.open_repo_on_github(remotes[1])
    end
  end, {
    cmd_opts = {
      bang = true,
      nargs = 0,
      desc = 'open chosen remote on GitHub, in the browser',
    },
    add_custom = true,
  })
end

-- sudowrite to file
utils.add_command('SudoWrite', function()
  vim.cmd [[
    write !sudo -A tee > /dev/null %
    edit
  ]]
end, {
  cmd_opts = { bang = true, nargs = 0, desc = 'sudo write' },
  add_custom = true,
})

-- messages in qflist
utils.add_command('Messages', misc.show_messages, {
  cmd_opts = { bang = false, nargs = 0, desc = 'show :messages in qflist', },
  add_custom = true
})

-- command output in qflist
utils.add_command('Show', misc.show_command, {
  cmd_opts = {
    bang = true,
    nargs = '+',
    complete = 'command',
    desc = 'run command, show output in qflist',
  }
})

-- <cword> highlight toggle
vim.cmd [[
  function! CWordHlToggle()
    let @/ = ''
    if exists('#auto_highlight')
      autocmd! auto_highlight
      augroup! auto_highlight

      set updatetime=1000
      lua require('utils').notify('<cword> highlight', 'debug', { title = '[UI] deactivated', render='compact' })
      return 0
    else
      augroup auto_highlight
        autocmd!
        autocmd CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
      augroup end

      set updatetime=250
      lua require('utils').notify('<cword> highlight', 'info', { title = '[UI] activated', render='compact' })
      return 1
    endif
  endfunction
]]

-- generate tags
utils.add_command('[MISC] Generate Tags', function(opts)
  local notification_opts = { title = '[MISC] tags', render = 'compact' }
  local notification_fn = (opts.silent and function(...)
      end) or utils.notify

  require('plenary').Job:new({
    command = 'ctags',
    args = { '-R', '--excmd=combine', '--fields=+K' },
    cwd = vim.loop.cwd(),
    on_start = core.partial(notification_fn, 'generating tags file', 'debug', notification_opts),
    on_exit = core.partial(notification_fn, 'generated tags file', 'info', notification_opts)
  }):start()
end, { add_custom = true })

-- toggles
utils.add_command('[UI] Toggle Context WinBar', misc.toggle_context_winbar, { add_custom = true })
utils.add_command('[UI] Toggle Thick Seperators', misc.toggle_thick_separators, { add_custom = true })
utils.add_command('[UI] Toggle Spellings', misc.toggle_spellings, { add_custom = true })
utils.add_command('[UI] Toggle Dark Mode', misc.toggle_dark_mode, { add_custom = true })
utils.add_command('[UI] Toggle CWord Highlights', 'if CWordHlToggle() | set hlsearch | endif', { add_custom = true })
utils.add_command('[UI] Rename buffer', misc.rename_buffer, { add_custom = true })
