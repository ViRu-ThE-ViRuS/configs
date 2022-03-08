local core = require("lib/core")

-- convert fzf items to locations
local fzf_to_locations = function(entry)
    local split = vim.split(entry, ":")
    local position = { line = tonumber(split[2]) - 1, character = tonumber(split[3]) - 1 }

    return {
        uri = vim.uri_from_fname(vim.fn.fnamemodify(split[1], ":p")),
        range = {start = position, ["end"] = position}
    }
end

-- populate qflist with fzf items
local fzf_to_qf = function(lines)
    local items = vim.lsp.util.locations_to_items(core.foreach(lines, fzf_to_locations))
    require("utils").qf_populate(items, "r")
end

-- strip filename from full path
local function strip_fname(path) return vim.fn.fnamemodify(path, ':t:r') end

-- get vim cwd
local function get_cwd() return vim.fn['getcwd']() end

-- get git repo root dir (or nil)
local function get_git_root()
    local git_cmd = 'git -C ' .. get_cwd() .. ' rev-parse --show-toplevel'
    local root, rc = core.lua_systemlist(git_cmd)

    if rc == 0 then return root[1] end
    return nil
end

-- open repository on github
-- NOTE(vir): using nvim-notify
local function open_repo_on_github(remote)
    if get_git_root() == nil then
        -- print("not in a git repository")
        require("notify")('not in a git repository', 'error',
                          {title = 'could not open on github', timeout = 250})
        return
    end

    remote = remote or 'origin'

    local url, rc = core.lua_system('git config remote.' .. remote .. '.url')
    if rc ~= 0 then
        -- print(string.format('found invalid remote url: [%s] -> %s', remote, url))
        require("notify")(string.format('found invalid remote url: [%s] -> %s', remote, url),
                          'error', {title = 'could not open on github', timeout = 250})
        return
    end

    url = url:gsub('git:', 'https://')
    url = url:gsub('git@', 'https://')
    url = url:gsub('com:', 'com/')
    core.lua_system('open -u ' .. url)

    -- print(string.format("opening remote in browser: [%s] -> %s", remote, url))
    require("notify")(string.format("[%s] -> %s", remote, url), 'info',
                      {title = 'opening remote in browser ', timeout = 250})
end

return {
    fzf_to_locations = fzf_to_locations,
    fzf_to_qf = fzf_to_qf,
    strip_fname = strip_fname,
    get_cwd = get_cwd,
    get_git_root = get_git_root,
    open_repo_on_github = open_repo_on_github
}
