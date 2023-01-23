local ffi = require('ffi')
local utils = require('utils')
ffi.cdef [[ int getuid(void); ]]

local function file_owned_by_me(file)
    return ffi.C.getuid() == vim.loop.fs_stat(file).uid
end

local function load()
    local local_rc_name = '.nvimrc.lua'

    if (vim.loop.fs_stat(local_rc_name)) then
        if (file_owned_by_me(local_rc_name)) then
            dofile(local_rc_name)
            utils.notify('sourced: ' .. local_rc_name, 'info', { title = '[CONFIG] loaded' })
        else
            utils.notify('permission error: ' .. local_rc_name, 'error', { title = '[CONFIG] load error' })
        end
    end
end

return { load = load }
