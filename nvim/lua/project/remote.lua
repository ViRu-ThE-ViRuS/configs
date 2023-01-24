local utils = require('utils')
local terminal = require('terminal')

-- project session state
local project_session = {
    target = nil, -- target ip address
    project_name = nil, -- name of the project

    host_path = nil, -- root path on host system, without trailing /
    target_path = nil, -- root path on target system, without trailing /

    host_user = nil, -- host username
    target_user = nil, -- target username
}

-- send project related notification
local function project_notify(content, type, opts)
    utils.notify(string.format('[%s] %s', project_session.target, content), type, opts)
end

-- launch host <-> target file sync
-- default is host -> target
-- reverse == true gives target -> host
local function launch_sync(reverse)
    print('here')
    if reverse then
        print('here')
        terminal.launch_terminal(
            string.format(
                'rsync -aP %s@%s:%s/ %s/',
                project_session.target_user,
                project_session.target,
                project_session.target_path,

                project_session.host_path
            ),
            false
        )
    else
        terminal.launch_terminal(
            string.format(
                'watch -n0.5 "rsync -aP %s/ %s@%s:%s/"',
                project_session.host_path,

                project_session.target_user,
                project_session.target,
                project_session.target_path
            ),
            true
        )
    end
end

-- launch project ssh
-- set_target == true, sets target_terminal after launch
-- cd into path, without trailing /, defaulted to project_session.target_path
local function launch_ssh(set_target, path)
    path = (path or project_session.target_path) .. '/'
    local to_path_cmd = 'cd ' .. path

    terminal.launch_terminal(
        string.format(
            'ssh -t %s@%s "%s"',
            project_session.target_user,
            project_session.target,
            to_path_cmd
        ),
        false,
        (set_target and terminal.set_target) or nil
    )
end

-- launch project session with ssh terminal
-- sync == true also launches project sync host -> target
local function launch_project_session(sync)
    local use_rsync = sync or false

    -- make ip updatable
    vim.ui.input({ prompt = "target gcp ip> ", default = project_session.target }, function(ip)
        if ip == nil then
            project_notify(
                string.format("invalid target ip: %s", project_session.target),
                "warn",
                { render = "minimal" }
            )
            return
        end

        -- MRU update to project target
        project_session.target = ip

        -- launch sync in background
        if use_rsync then launch_sync() end

        -- launch ssh terminal
        launch_ssh(true)
        project_notify("project session launched", "info", { render = 'minimal' })
    end)
end

-- set project session/state
local function set_project_session(session)
    assert(session.target, 'session must have a `target` ip')
    assert(session.project_name, 'session must have a `project_name`')
    assert(session.host_path, 'session must have a `host_path`')
    assert(session.target_path, 'session must have a `target_path`')
    assert(session.host_user, 'session must have a `host_user` name')
    assert(session.target_user, 'session must have a `target_user` name')
    project_session = session

    project_notify("project session configured", "info", { render = 'minimal' })
end

return {
    set_project_session = set_project_session,
    launch_sync = launch_sync,
    launch_ssh = launch_ssh,
    launch_project_session = launch_project_session,
}
