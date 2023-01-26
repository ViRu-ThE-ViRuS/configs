local class = require('lib/class').class
local terminal = require('terminal')

-- Project class
local Project = class()
-- {{{ Project api
function Project:init(
    name,
    host_user,
    host_path
)
    self.name = name
    self.target_path  = host_user
    self.host_path    = host_path
end

function Project:notify(content, type, opts)
    require('utils').notify(string.format('[%s] %s', self.name, content), type, opts)
end
-- }}}

-- RemoteProject class
local RemoteProject = class(Project)
-- {{{ RemoteProject api
function RemoteProject:init(
    -- Project
    name,
    host_user,
    host_path,

    -- Remote
    target,
    target_user,
    target_path
)
    -- TODO(vir): figure out how to call parent constructor
    self.name = name
    self.host_user = host_user
    self.host_path = host_path

    self.target = target
    self.target_user = target_user
    self.target_path = target_path
end

function RemoteProject:launch_sync(reverse)
    if reverse then
        terminal.launch_terminal(
            string.format(
                'rsync -aP %s@%s:%s/ %s',
                self.target_user,
                self.target,
                self.target_path,
                self.host_path
            ),
            false
        )
    else
        terminal.launch_terminal(
            string.format(
                'watch -n0.5 "rsync -aP %s/ %s@%s:%s/"',
                self.host_path,

                self.target_user,
                self.target,
                self.target_path
            ),
            true
        )
    end
end

function RemoteProject:launch_ssh(set_target, path)
    path = (path or self.target_path) .. '/'
    local to_path_cmd = 'cd ' .. path

    terminal.launch_terminal(
        string.format(
            'ssh -t %s@%s "%s"',
            self.target_user,
            self.target,
            to_path_cmd
        ),
        false,
        (set_target and terminal.set_target) or nil
    )
end

function RemoteProject:launch_project_session(sync)
    local use_rsync = sync or false

    -- make ip updatable
    vim.ui.input({ prompt = "target gcp ip> ", default = self.target }, function(ip)
        if ip == nil then
            self:notify(
                string.format("invalid target ip: %s", self.target),
                "warn",
                { render = "minimal" }
            )
            return
        end

        -- MRU update to project target
        self.target = ip

        -- launch sync in background
        if use_rsync then self:launch_sync(false) end

        -- launch ssh terminal
        self:launch_ssh(true)
        self:notify("project session launched", "info", { render = 'minimal' })
    end)
end
-- }}}

return {
    Project = Project,
    RemoteProject = RemoteProject
}

