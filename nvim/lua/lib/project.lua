local class = require('lib/class')
local core = require('lib/core')
local terminal = require('lib/terminal')
local utils = require('utils')

-- Project class
local Project = class()
Project.default_args = { host_user = core.get_username(), host_path = vim.fn.getcwd(), ignore_paths = 'venv' }

-- {{{ Project api

--- Initialize a new Project instance.
-- @param args Table containing project arguments.
-- @field args.name (string) The name of the project.
-- @field args.host_user (string) The user on the host machine.
-- @field args.host_path (string) The path on the host machine.
-- @field args.ignore_paths (string) Additional paths to nvim to ignore.
function Project:init(args)
  args = vim.tbl_deep_extend('force', Project.default_args, args or {})
  assert(args.name, 'project name cannot be nil')

  self.args         = args
  self.name         = args.name

  self.host_user    = args.host_user
  self.host_path    = args.host_path
  self.ignore_paths = args.ignore_paths

  self.command_keys = {}
  self.dap_config   = {}

  if self.ignore_paths then
    require('lib/local_session').override_session_config({
      fuzzy_ignore_dirs = self.ignore_paths .. ',' .. session.config.fuzzy_ignore_dirs
    })
  end
end

--- Send a project-scoped notification.
-- @param content (string) The content of the notification.
-- @param type (string) The type of the notification.
-- @param opts (table) Additional options for the notification.
function Project:notify(content, type, opts)
  utils.notify(string.format('[%s] %s', self.name, content), type, opts)
end

--- Add a project-scoped command.
-- @param name (string) The name of the command.
-- @param callback (function) The callback function to execute.
function Project:add_command(name, callback)
  local key = utils.add_command(string.format('[%s] %s', self.name, name), callback, { add_custom = true })
  self.command_keys[key] = 1
end

--- Run a project-scoped command.
-- @param key (string) The key of the command to run.
function Project:run_command(key)
  key = string.format('[%s] %s', self.name, key)
  assert(self.command_keys[key], 'project command was not registered: ' .. key)
  return utils.run_command(key)
end

--- Add a project DAP (Debug Adapter Protocol) configuration.
-- @param name (string) The name of the DAP configuration.
-- @param program (string) The program to debug.
-- @param args (table) Arguments for the program.
-- @param opts (table) Additional options for the DAP configuration.
function Project:add_dap_config(name, program, args, opts)
  assert(program, 'invalid program specified: ' .. program)
  args = args or {}

  -- extra opts for runner
  opts = vim.tbl_deep_extend('force', {
    base_type = nil,
    preamble = nil,
  }, opts or {})

  assert(opts.base_type, 'opts.base_type must be specified as this is the base DAP config which will be launched')
  self.dap_config[name] = { program = program, args = args, _opts = opts }
end

-- }}}

-- RemoteProject class
local RemoteProject = class(Project)
RemoteProject.default_args = {}

-- {{{ RemoteProject api

--- Initialize a new RemoteProject instance.
-- @param args Table containing remote project arguments.
-- @field target (string) The remote target.
-- @field target_user (string) The user on the remote target.
-- @field target_path (string) The path on the remote target.
function RemoteProject:init(args)
  args = vim.tbl_deep_extend('force', RemoteProject.default_args, args or {})
  self.super:init(args) -- init superclass

  assert(args.target, 'target cannot be nil')
  assert(args.target_user, 'target_user cannot be nil')
  assert(args.target_path, 'target_path cannot be nil')

  self.target      = args.target
  self.target_user = args.target_user
  self.target_path = args.target_path
end

--- Launch rsync synchronization between host and remote target.
-- @param opts (table) Options for synchronization.
-- @field type (string) The type of synchronization ('rsync' or 'lsync').
-- @field rsync_opts (table) Options for rsync.
-- @field lsync_opts (table) Options for lsync.
function RemoteProject:launch_sync(opts)
  local default_sync_opts = {
    type = 'lsync',
    rsync_opts = { use_session_ignores = true, reverse = false },
    lsync_opts = { config_str = nil },
  }
  opts = vim.tbl_deep_extend('force', default_sync_opts, opts or {})

  local function _launch_rsync()
    local exclude_str = ""

    if opts.use_session_ignores then
      for path in string.gmatch(session.config.fuzzy_ignore_dirs, "([^,]+)") do
        exclude_str = exclude_str .. string.format('--exclude "%s" ', path)
      end
    end

    if opts.rsync_opts.reverse then
      terminal.launch_terminal(
        string.format('rsync -aP %s %s@%s:%s/ %s',
          exclude_str, self.target_user, self.target, self.target_path, self.host_path))
    else
      terminal.launch_terminal(
        string.format('watch -n0.5 "rsync -aP %s %s/ %s@%s:%s/"', exclude_str, self.host_path, self.target_user,
          self.target, self.target_path),
        { background = true })
    end
  end

  local function _launch_lsync()
    assert(opts.lsync_opts.config_str and opts.lsync_opts.config_str ~= "", "lyncconfig string cant be nil")

    local path = core.create_file('/tmp/.lsyncconfig', {
      content = opts.lsync_opts.config_str,
      add_uuid = true
    })

    terminal.launch_terminal(
      string.format('lsyncd %s --delay 0', path),
      { background = true }
    )
  end

  if opts.type == 'rsync' then
    _launch_rsync()
  elseif opts.type == 'lsync' then
    _launch_lsync()
  end
end

--- Launch an SSH session from host to remote target.
-- @param opts (table) Options for the SSH session.
-- @field opts.path (string) The path to navigate to on the remote target.
-- @field opts.callback (function) Callback function to call from within terminal buffer
function RemoteProject:launch_ssh(opts)
  opts = vim.tbl_deep_extend('force', { path = self.target_path, callback = nil }, opts or {})
  local to_path_cmd = 'cd ' .. opts.path .. ' ; bash --'

  return terminal.launch_terminal(
    string.format('ssh -t %s@%s "%s"', self.target_user, self.target, to_path_cmd),
    {
      add = true,
      callback = opts.callback
    }
  )
end

-- }}}

-- {{{ Project.remote() factory

--- Detect if a sync target is a ClusterTarget (has clusters field).
-- @param sync_target The sync target to check.
-- @return (boolean) True if it's a ClusterTarget.
local function is_cluster_target(sync_target)
  return sync_target.clusters ~= nil
end

--- Create a remote project with auto-generated sync commands.
-- Supports both SyncTarget and ClusterTarget.
-- @param opts Table containing remote project options.
-- @field opts.name (string) The name of the project.
-- @field opts.sync_target (SyncTarget|ClusterTarget) The sync target configuration.
-- @field opts.commands (table) Optional custom commands to add.
-- @field opts.host_path (string) Optional host path (defaults to cwd).
-- @field opts.ignore_paths (string) Optional ignore paths.
-- @return (RemoteProject) Configured remote project instance.
local function create_remote_project(opts)
  assert(opts.name, 'name cannot be nil')
  assert(opts.sync_target, 'sync_target cannot be nil')

  local sync_target = opts.sync_target
  local is_cluster = is_cluster_target(sync_target)

  -- Create project with placeholder target (resolved lazily)
  -- For ClusterTarget, user/path are resolved dynamically
  local project = RemoteProject.new({
    name = opts.name,
    target = '', -- Will be resolved lazily
    target_user = is_cluster and '' or sync_target.user,
    target_path = is_cluster and '' or sync_target.path,
    host_path = opts.host_path,
    ignore_paths = opts.ignore_paths,
  })

  -- Store sync_target reference on project
  project.sync_target = sync_target

  -- Helper to update project fields after host resolution (for ClusterTarget)
  local function update_project_from_cluster()
    if is_cluster then
      project.target_user = sync_target:get_user()
      project.target_path = sync_target:get_path()
    end
  end

  -- Auto-generate Launch Sync command
  project:add_command('Launch Sync', function()
    sync_target:resolve_host(false, function(host)
      if not host then
        project:notify('No hosts available', 'error')
        return
      end

      -- Update project target for compatibility with existing code
      project.target = host
      update_project_from_cluster()

      local config = sync_target:lsyncd_config(project.host_path)
      if not config then
        project:notify('Failed to generate lsyncd config', 'error')
        return
      end

      local path = core.create_file('/tmp/.lsyncconfig', {
        content = config,
        add_uuid = true
      })

      terminal.launch_terminal(
        string.format('lsyncd %s --delay 0', path),
        { background = true }
      )

      -- Notify with cluster info for ClusterTarget
      if is_cluster then
        local cluster_name = sync_target:get_cluster_name()
        project:notify(string.format('Syncing to %s (%s)', host, cluster_name), 'info')
      end
    end)
  end)

  -- Auto-generate Launch SSH command
  project:add_command('Launch SSH', function()
    sync_target:resolve_host(false, function(host)
      if not host then
        project:notify('No hosts available', 'error')
        return
      end

      project.target = host
      update_project_from_cluster()
      project:launch_ssh()
    end)
  end)

  -- Auto-generate Select Host command
  project:add_command('Select Host', function()
    sync_target:resolve_host(true, function(host)
      if host then
        project.target = host
        update_project_from_cluster()

        if is_cluster then
          local cluster_name = sync_target:get_cluster_name()
          project:notify(string.format('Selected host: %s (%s)', host, cluster_name), 'info')
        else
          project:notify(string.format('Selected host: %s', host), 'info')
        end
      end
    end)
  end)

  -- Add custom commands if provided
  if opts.commands then
    for name, callback in pairs(opts.commands) do
      project:add_command(name, function()
        callback(project)
      end)
    end
  end

  return project
end

-- }}}

-- {{{ Presets

local nvidia_presets = require('lib/presets/nvidia')

-- }}}

return {
  Project = Project,
  RemoteProject = RemoteProject,
  remote = create_remote_project,
  presets = nvidia_presets,
}

--[[ example usage in .nvimrc.lua

-- === CLUSTER TARGET API (recommended for multi-cluster projects) ===
local sync = require('lib/sync')
local Project = require('lib/project')

return Project.remote({
  name = 'inference-endpoint',
  sync_target = sync.cluster_target({
    clusters = Project.presets.nvidia_clusters,
    project_subdir = 'mlperf/inference-endpoint',  -- just the subdir!
    excludes = { 'build/', '.cache', 'venv', '__pycache__' },
  }),
})

-- === SYNC TARGET API (single host/user/path) ===
return Project.remote({
  name = 'my-project',
  sync_target = sync.target({
    host = Project.presets.nvidia_internal_hosts, -- Lazy! Fetches nodes when sync starts
    user = 'username',
    path = '/remote/path/to/project/',
    excludes = { 'build/', '.cache', 'venv', '__pycache__' },
  }),
  -- Optional custom commands
  commands = {
    ['Custom Command'] = function(project)
      -- your code here
    end,
  },
})

-- === LEGACY API (still supported) ===
local terminal = require('lib/terminal')
local LegacyProject = require('lib/project').Project

local project = LegacyProject.new({ name = "meshedit" })
project.executable = string.format('%s/build/%s', vim.fn.getcwd(), project.name)

project:add_command('build', function()
  terminal.send_to_terminal('cd build ; make ; cd ..')
end)

project:add_dap_config('basic', project.executable, { 'bzc/curve1.bzc' }, {
  base_type = 'cpp',
  preamble = function(_) project:run_command('build') end
})

return project

--]]
