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
local function load_local_session()
  local utils = require('utils')
  local local_rc_name = session.config.local_rc_name

  -- return if local rc doesn't exist, or if it is not owned by current user
  if not file_owned_by_me(local_rc_name) then return end

  -- execute local rc and load project if specified
  session.state.project = dofile(local_rc_name)
  utils.notify('sourced: ' .. local_rc_name, 'info', { title = '[CONFIG] session loaded' })

  if session.state.project then
    vim.cmd.doautocmd({ 'User ProjectInit' })
    session.state.project:notify('configured', 'debug', { render = 'minimal' })
  end
end

return {
  override_session_config = override_session_config,
  load_local_session = load_local_session,
}

--[[ example usage in .nvimrc.lua

-- override / append to session configs
require('lib/local_session').override_session_config({
  fuzzy_ignore_dirs = session.config.fuzzy_ignore_dirs .. ',lazy_lock.json'
})

--]]
