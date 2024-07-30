local class = require('lib/class')
local core = require('lib/core')
local terminal = require('lib/terminal')
local utils = require('utils')

-- Project class
local Project = class()
Project.default_args = { host_user = core.get_username(), host_path = vim.fn.getcwd(), ignore_paths = 'venv' }

-- {{{ Project api
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

-- send a project-scoped notification
function Project:notify(content, type, opts)
  utils.notify(string.format('[%s] %s', self.name, content), type, opts)
end

-- add a project-scoped command
function Project:add_command(name, callback)
  local key = utils.add_command(string.format('[%s] %s', self.name, name), callback, { add_custom = true })
  self.command_keys[key] = 1
end

-- run project-scoped command
function Project:run_command(key)
  key = string.format('[%s] %s', self.name, key)
  assert(self.command_keys[key], 'project command was not registered: ' .. key)
  utils.run_command(key)
end

-- add project-dap config
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

-- launch rsync host <-> remote target
function RemoteProject:launch_sync(reverse)
  local exclude_str = ""
  for path in string.gmatch(session.config.fuzzy_ignore_dirs, "([^,]+)") do
    exclude_str = exclude_str .. string.format('--exclude "%s" ', path)
  end

  if reverse then
    terminal.launch_terminal(
      string.format(
        'rsync -aP %s %s@%s:%s/ %s',
        exclude_str,
        self.target_user,
        self.target,
        self.target_path,
        self.host_path
      )
    )
  else
    terminal.launch_terminal(
      string.format(
        'watch -n0.5 "rsync -aP %s %s/ %s@%s:%s/"',
        exclude_str,
        self.host_path,
        self.target_user,
        self.target,
        self.target_path
      ),
      { background = true }
    )
  end
end

-- launch ssh session host -> remote target
function RemoteProject:launch_ssh(set_target, path)
  path = (path or self.target_path) .. '/'
  local to_path_cmd = 'cd ' .. path .. ' ; bash --'

  terminal.launch_terminal(
    string.format('ssh -t %s@%s "%s"', self.target_user, self.target, to_path_cmd),
    { callback = (set_target and core.partial(terminal.add_terminal, { primary = true })) or nil }
  )
end

-- launch a procject session: ssh and/or rsync host -> remote
function RemoteProject:launch_project_session(sync)
  -- make ip updatable
  vim.ui.input({ prompt = "target gcp ip> ", default = self.target }, function(ip)
    if ip == nil then
      self:notify(string.format("invalid target ip: %s", self.target), "warn", { render = "minimal" })
      return
    end

    -- MRU update to project target
    self.target = ip

    -- launch sync in background
    if sync then self:launch_sync(false) end

    -- launch ssh terminal
    self:launch_ssh(true)
    self:notify("project session launched", "info", { render = 'minimal' })
  end)
end

-- }}}

-- FileSyncProject class
FileSyncProject = class(RemoteProject)
FileSyncProject.default_args = { target = 'localhost', target_user = core.get_username() }

-- {{{ FileSyncProject api
function FileSyncProject:init(args)
  args = vim.tbl_deep_extend('force', FileSyncProject.default_args, args or {})
  self.super:init(args) -- init superclass
end

-- }}}

return {
  Project = Project,
  RemoteProject = RemoteProject,
  FileSyncProject = FileSyncProject
}

--[[ example usage in .nvimrc.lua

local terminal = require('lib/terminal')
local Project = require('lib/project').Project

-- create a project
local project = Project.new({ name = "meshedit" })
project.executable = string.format('%s/build/%s', vim.loop.cwd(), project.name)

-- add a command
project:add_command('build', function()
terminal.send_to_terminal('cd build ; make ; cd ..')
end)

-- add a debug config
project:add_dap_config('basic', project.executable, { 'bzc/curve1.bzc' }, {
base_type = 'cpp',
preamble = function(_) project:run_command('build') end
})

-- MUST RETURN THIS PROJECT OBJECT, so as to register it into the session
return project

--]]
