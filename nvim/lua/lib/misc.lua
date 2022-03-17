local core = require("lib/core")
local notify = require('notify')

-- convert fzf items to locations
local function fzf_to_location(entry)
    local split = vim.split(entry, ":")
    local _, line = pcall(tonumber, split[2])
    local _, character = pcall(tonumber, split[3])

    line = line and line - 1
    character = character or 0

    local position = { line = line, character = character }
    return {
        uri = vim.uri_from_fname(vim.fn.fnamemodify(split[1], ":p")),
        range = {start = position, ["end"] = position}
    }
end

-- populate qflist with fzf items
local function fzf_to_qf(lines)
    local items = vim.lsp.util.locations_to_items(core.foreach(lines, fzf_to_location), 'utf-16')
    require("utils").qf_populate(items, "r")
end

-- strip filename from full path
local function strip_fname(path) return vim.fn.fnamemodify(path, ':t:r') end

-- strip trailing whitespaces in file
local function strip_trailing_whitespaces()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_command('%s/\\s\\+$//e')
    vim.api.nvim_win_set_cursor(0, cursor)
end

-- get vim cwd
local function get_cwd() return vim.fn['getcwd']() end

-- get git repo root dir (or nil)
local function get_git_root()
    local git_cmd = 'git -C ' .. get_cwd() .. ' rev-parse --show-toplevel'
    local root, rc = core.lua_systemlist(git_cmd)

    if rc == 0 then return root[1] end
    return nil
end

-- get git remote names
local function get_git_remotes()
    local table, rc = core.lua_systemlist('git remote -v | cut -f 1 | uniq')
    if rc ~= 0 then
        return {}
    end

    return table
end

-- open repository on github
-- NOTE(vir): using nvim-notify
local function open_repo_on_github(remote)
    if get_git_root() == nil then
        notify('not in a git repository', 'error',
               {title = 'could not open on github'})
        return
    end

    remote = remote or 'origin'

    local url, rc = core.lua_system('git config remote.' .. remote .. '.url')
    if rc ~= 0 then
        notify(string.format('found invalid remote url: [%s] -> %s', remote, url),
              'error', {title = 'could not open on github'})
        return
    end

    url = url:gsub('git:', 'https://')
    url = url:gsub('git@', 'https://')
    url = url:gsub('com:', 'com/')
    core.lua_system('open -u ' .. url)

    notify(string.format("[%s] -> %s", remote, url), 'info',
          {title = 'opening remote in browser'})
end

-- window: toggle state, keep track of window ids
local state = {}

-- window: toggle current window (maximum <-> original)
local function toggle_window()
    if vim.fn.winnr('$') > 1 then
        local original = vim.fn.win_getid()
        vim.cmd('tab sp')
        state[vim.fn.win_getid()] = original
    else
        local maximized = vim.fn.win_getid()
        local original = state[maximized]

        if original ~= nil then
            vim.cmd('tabclose')
            vim.fn.win_gotoid(original)
            state[maximized] = nil
        end
    end
end

return {
    fzf_to_qf = fzf_to_qf,
    strip_fname = strip_fname,
    strip_trailing_whitespaces = strip_trailing_whitespaces,
    get_cwd = get_cwd,
    get_git_root = get_git_root,
    get_git_remotes = get_git_remotes,
    open_repo_on_github = open_repo_on_github,
    toggle_window = toggle_window
}
