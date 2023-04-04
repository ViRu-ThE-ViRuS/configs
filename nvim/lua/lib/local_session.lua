local ffi = require('ffi')
ffi.cdef [[ int getuid(void); ]]

-- is file owned by current user
local function file_owned_by_me(file)
  local fs_stat = vim.loop.fs_stat(file)
  return fs_stat and ffi.C.getuid() == fs_stat.uid
end

-- override session defaults (sesison.config)
local function override_session_config(config)
  session.config = vim.tbl_deep_extend('force', session.config, config or {})
end

-- execute local rc
local function load_local_session(silent)
  local utils = require('utils')
  local local_rc_name = session.config.local_rc_name

  -- return if local rc doesn't exist, or if it is not owned by current user
  if not file_owned_by_me(local_rc_name) then return end

  -- execute local rc and load project if specified
  session.state.project = dofile(local_rc_name)

  if not silent then
    utils.notify(
      'sourced: ' .. local_rc_name,
      'info',
      { title = '[CONFIG] session loaded' }
    )
  end

  if session.state.project then
    vim.cmd.doautocmd({ 'User ProjectInit' })

    if not silent then
      session.state.project:notify('configured', 'debug', { render = 'minimal' })
    end
  end
end

-- {{{ presets
-- start syncing ctags file for this project based on event and filetypes
-- like on BufWritePost for all c, cpp and related files
local function sync_ctags(opts)
  opts = vim.tbl_deep_extend('force', {
    filetypes = '*.c,*.cpp,*.h,*.hpp',
    event = 'BufWritePost'
  }, opts or {})

  vim.api.nvim_create_autocmd('BufWritePost', {
    group = 'Session',
    pattern = opts.filetypes,
    callback = require('lib/core').partial(require('utils').run_command, '[MISC] Generate Tags', {
      silent = true,

      -- need to pass silent argument to command
      -- as this is a long running command
      args = { { silent = true } },
    })
  })
end
-- }}}

return {
  override_session_config = override_session_config,
  load_local_session = load_local_session,
  sync_ctags = sync_ctags,
}

--[[ example usage in .nvimrc.lua

-- override / append to session configs
local local_session = require('lib/local_session')

-- customize session
local_session.override_session_config({
  fuzzy_ignore_dirs = session.config.fuzzy_ignore_dirs .. ',lazy_lock.json'
})

-- use a preset
local_session.sync_ctags()

--]]
