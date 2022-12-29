-- create table (key, value) -> (key, f(key, value))
local function foreach(tbl, f)
    if not tbl then return {} end

    local t = {}
    for key, value in pairs(tbl) do t[key] = f(key, value) end
    return t
end

-- create table (_, value) -> (_, f(key, value))
local function apply(tbl, f)
    if not tbl then return {} end

    local t = {}
    for key, value in pairs(tbl) do table.insert(t, f(key, value)) end
    return t
end

-- filter using predicate f
local function filter(tbl, f, keep_keys)
    if not tbl or tbl == {} then return {} end

    local t = {}

    local insert = function(key, value)
        if keep_keys then t[key] = value
        else table.insert(t, value) end
    end

    for key, value in pairs(tbl) do
        if f(key, value) then insert(key, value) end
    end

    return t
end

-- concatenate two tables
local function list_concat(A, B)
    local t = {}

    if A then
        for _, value in ipairs(A) do
            table.insert(t, value)
        end
    end

    if B then
        for _, value in ipairs(B) do
            table.insert(t, value)
        end
    end

    return t
end

-- return index if table contains given value
local function table_contains(table, target_value)
    for key, value in pairs(table) do
        if value == target_value then return key end
        if key == target_value then return value end
    end

    return nil
end

-- run shell command and get output lines as lua table
-- from: https://github.com/ibhagwan/fzf-lua/blob/main/lua/fzf-lua/utils.lua
local function lua_systemlist(cmd)
    local stdout, rc = {}, nil
    local handle = io.popen(cmd .. ' 2>&1 ; echo $?', 'r')

    if handle then
        for line in handle:lines() do stdout[#stdout + 1] = line end
        rc = tonumber(stdout[#stdout])
        stdout[#stdout] = nil
        handle:close()
    end

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
-- NOTE(vir): never loose ur way enough to be using windows
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
    apply = apply,
    filter = filter,
    list_concat = list_concat,
    table_contains = table_contains,

    lua_systemlist = lua_systemlist,
    lua_system = lua_system,

    get_python = get_python,
    get_username = get_username,
    get_homedir = get_homedir,
    get_os = get_os
}
