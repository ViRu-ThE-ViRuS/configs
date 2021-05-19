M = {}

-- get operating system name ("Linux", "macOS")
local get_os = function(table)
    if table == nil then
        table = {
            macOs = 'macOS',
            linux = 'Linux'
        }
    end

    if vim.api.nvim_exec('echo system("uname -s")', true):find("Darwin") then
        return table.macOs
    else
        return table.linux
    end
end
M.get_os = get_os

-- trim leading / trailing whitespace from string
local trim = function(s)
   return s:match "^%s*(.-)%s*$"
end

-- get username ($USER)
local get_username = function()
    return trim(vim.api.nvim_exec('echo system("echo $USER")', true))
end
M.get_username = get_username

-- get home dir ("/home/viraat-chandra", "/Users/viraat-chandra")
M.get_homedir = function()
    if get_os() == 'macOS' then
        return '/Users/' .. get_username()
    else
        return '/home/' .. get_username()
    end
end

return M
