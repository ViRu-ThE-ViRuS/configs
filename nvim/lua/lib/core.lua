-- create table (key, value) -> (key, f(key, value))
-- if only_values is set, this returns (key, value) -> (f(key, value)) [flat array]
local function foreach(tbl, f, only_values)
  if not tbl then return {} end

  local t = {}
  if only_values then for key, value in pairs(tbl) do table.insert(t, f(key, value)) end
  else for key, value in pairs(tbl) do t[key] = f(key, value) end end
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
    if keep_keys then
      t[key] = value
    else
      table.insert(t, value)
    end
  end

  for key, value in pairs(tbl) do
    if f(key, value) then insert(key, value) end
  end

  return t
end

-- currying functions, fn(params) will be called on partial()
local function partial(fn, ...)
  local n, args = select('#', ...), { ... }
  return function()
    return fn(unpack(args, 1, n))
  end
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
local function table_contains(tbl, target_value)
  for key, value in pairs(tbl) do
    if value == target_value then return key end
    if key == target_value then return value end
  end

  return nil
end

-- return copy of table
local function table_copy(t)
  local u = {}
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

-- return table of keys
local function table_keys(tbl)
  local keys = {}
  for key, _ in pairs(tbl) do
    table.insert(keys, key)
  end

  return keys
end

-- checks if all (key, value) pairs exist in both tables
local function table_equal(left, right)
  for key, value in pairs(left) do
    if (type(key) == 'table' and ((not right[key]) or (not table_equal(value, right[key])))) or
       (type(key) ~= 'table' and ((not right[key]) or (right[key] ~= value))) then
      return false
    end
  end

  for key, value in pairs(right) do
    if (type(key) == 'table' and ((not left[key]) or (not table_equal(value, left[key])))) or
       (type(key) ~= 'table' and ((not left[key]) or (left[key] ~= value))) then
      return false
    end
  end

  return true
end

-- checks if all (key, value) pairs in child are present in parent
local function table_subset(parent, child)
  for key, value in pairs(child) do
    if (type(key) == 'table' and ((not parent[key]) or (not table_equal(value, parent[key])))) or
      (type(key) ~= 'table' and ((not parent[key]) or (parent[key] ~= value))) then
      return false
    end
  end

  return true
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
  if table == nil then table = { macOS = 'macOS', linux = 'Linux' } end

  if os.getenv('HOME'):find('/Users') then
    return table.macOS
  else
    return table.linux
  end
end

return {
  foreach        = foreach,
  apply          = apply,
  filter         = filter,
  list_concat    = list_concat,
  partial        = partial,
  table_contains = table_contains,
  table_copy     = table_copy,
  table_keys     = table_keys,
  table_equal    = table_equal,
  table_subset   = table_subset,
  lua_systemlist = lua_systemlist,
  lua_system     = lua_system,
  get_python     = get_python,
  get_username   = get_username,
  get_homedir    = get_homedir,
  get_os         = get_os,
}
