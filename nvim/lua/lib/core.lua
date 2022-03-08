-- optimization
-- from: https://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
local next = next

-- apply f to all elements in table
local function foreach(tbl, f)
    local t = {}
    for key, value in ipairs(tbl) do t[key] = f(value) end
    return t
end

-- filter using predicate f
local function filter(tbl, f)
    if not tbl or tbl == {} then return {} end

    local t = {}
    for key, value in ipairs(tbl) do
        if f(key, value) then table.insert(t, value) end
    end

    return t
end

-- pos in range
local in_range = function(pos, range)
    if pos[1] < range['start'].line or pos[1] > range['end'].line then
        return false
    end

    if (pos[1] == range['start'].line and pos[2] < range['start'].character) or
        (pos[1] == range['end'].line and pos[2] > range['end'].character) then
        return false
    end

    return true
end

-- run shell command and get output lines as lua table
-- from: https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
local function lua_systemlist(cmd)
    local stdout, rc = {}, 0
    local handle = io.popen(cmd .. ' 2>&1 ; echo $?', 'r')

    if handle then
        for line in handle:lines() do stdout[#stdout + 1] = line end
        rc = tonumber(stdout[#stdout])
        stdout[#stdout] = nil
    end

    handle:close()
    return stdout, rc
end

-- run shell command and get str output
local function lua_system(cmd)
    local stdout, rc = lua_systemlist(cmd)
    if next(stdout) == nil then return nil, rc end
    return table.concat(stdout, '\n'), rc
end

-- get which python3 in current env
-- NOTE(vir): assuming python3 exists on all systems
local function get_python()
    local python, _ = lua_system('which python3')
    return python
end

-- get username ($USER)
local function get_username() return os.getenv('USER') end

-- get home dir ($HOME)
local function get_homedir() return os.getenv('HOME') end

-- get operating system name
local function get_os(table)
    if table == nil then table = {macOS = 'macOS', linux = 'Linux'} end

    if os.getenv('HOME'):find('/Users') then
        return table.macOS
    else
        return table.linux
    end
end

return {
    foreach = foreach,
    filter = filter,
    in_range = in_range,
    lua_systemlist = lua_systemlist,
    lua_system = lua_system,
    get_python = get_python,
    get_username = get_username,
    get_homedir = get_homedir,
    get_os = get_os
}
