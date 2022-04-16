local core = require("lib/core")

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
local function get_cwd() return vim.fn.getcwd() end

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
    local notify = require('notify')

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
local window_state = {}

-- window: toggle current window (maximum <-> original)
local function toggle_window()
    if vim.fn.winnr('$') > 1 then
        local original = vim.fn.win_getid()
        vim.cmd('tab sp')
        window_state[vim.fn.win_getid()] = original
    else
        local maximized = vim.fn.win_getid()
        local original = window_state[maximized]

        if original ~= nil then
            vim.cmd('tabclose')
            vim.fn.win_gotoid(original)
            window_state[maximized] = nil
        end
    end
end

-- separator: toggle state, between thick and default
local separator_state = false

-- separator: toggle buffer separators (thick <-> default)
-- NOTE(vir): using nvim-notify
local function toggle_thicc_separators()
    if separator_state then
        vim.opt.fillchars = {
            horiz = nil,
            horizup = nil,
            horizdown = nil,
            vert = nil,
            vertleft = nil,
            vertright = nil,
            verthoriz = nil
        }

        separator_state = false
        require('notify')('thiccness dectivated', 'debug', {render = 'minimal'})
    else
        vim.opt.fillchars = {
            horiz = '━',
            horizup = '┻',
            horizdown = '┳',
            vert = '┃',
            vertleft = '┫',
            vertright = '┣',
            verthoriz = '╋',
        }

        separator_state = true
        require('notify')('thiccness activated', 'info', {render = 'minimal'})
    end
end

-- spellings: toggle spellings globally
-- NOTE(vir): using nvim-notify
local function toggle_spellings()
    if vim.api.nvim_get_option_value('spell', {scope='global'}) then
        vim.opt.spell = false
        require('notify')('spellings deactivated', 'debug', {render = 'minimal'})
    else
        vim.opt.spell = true
        require('notify')('spellings activated', 'info', {render = 'minimal'})
    end
end

-- laststatus: toggle between global and local statusline
local function toggle_global_statusline()
    if vim.api.nvim_get_option_value('laststatus', {scope='global'}) == 3 then
        vim.opt.laststatus = 2
        require('notify')('global statusline deactivated', 'debug', {render = 'minimal'})
    else
        vim.opt.laststatus = 3
        require('notify')('global statusline activated', 'debug', {render = 'minimal'})
    end
end

-- quickfix: toggle qflist
local function toggle_qflist()
    if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) == 1 then
        vim.cmd [[ belowright copen ]]
    else
        vim.cmd [[ cclose ]]
    end
end

-- send :messages to qflist
local function show_messages()
    local messages = vim.api.nvim_exec('messages', true)
    local entries = {}

    for _, line in ipairs(vim.split(messages, '\n', true)) do
        table.insert(entries, { text = line })
    end

    require("utils").qf_populate(entries, 'r', "setlocal statusline=%!v:lua.StatusLine('Messages')")
end

return {
    fzf_to_qf = fzf_to_qf,
    strip_fname = strip_fname,
    strip_trailing_whitespaces = strip_trailing_whitespaces,
    get_cwd = get_cwd,
    get_git_root = get_git_root,
    get_git_remotes = get_git_remotes,
    open_repo_on_github = open_repo_on_github,
    toggle_window = toggle_window,
    toggle_thicc_separators = toggle_thicc_separators,
    toggle_spellings = toggle_spellings,
    toggle_global_statusline = toggle_global_statusline,
    toggle_qflist = toggle_qflist,
    show_messages = show_messages
}

