local ffi = require('ffi')
ffi.cdef [[ int getuid(void); ]]

-- is file owned by current user
local function file_owned_by_me(file)
  local fs_stat = vim.loop.fs_stat(file)
  return fs_stat and ffi.C.getuid() == fs_stat.uid
end

-- override session defaults (sesison.config)
local function override_session_config(config)
  session.config = vim.tbl_deep_extend('force', session.config, config)
end

-- execute local rc
local function load_local_session()
  local utils = require('utils')
  local local_rc_name = session.config.local_rc_name

  -- TODO(vir): fix this, can lead to arbit. Code Execution exploits
  --            file_owned_by_me protection is not enough

  -- return if local rc doesn't exist, or if it is not owned by current user
  if not file_owned_by_me(local_rc_name) then return end

  -- execute local rc and load project if specified
  session.state.project = dofile(local_rc_name)
  utils.notify('sourced: ' .. local_rc_name, 'info', { title = '[CONFIG] session loaded' })

  if session.state.project then
    vim.defer_fn(function()
      -- TODO(vir): test this out, after the session.lua refactor
      -- NOTE(vir): for some reason, this only works when deferred
      -- initialize project settings
      vim.cmd.doautocmd({ 'User ProjectInit' })
      session.state.project:notify('Configured', 'debug', { render = 'minimal' })
    end, 0)
  end
end

return {
  override_session_config = override_session_config,
  load_local_session = load_local_session,
}
