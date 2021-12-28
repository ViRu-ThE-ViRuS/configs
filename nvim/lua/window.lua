-- module export
M = {}

-- state, keep track of window ids
local state = {}

-- toggle current window (maximum <-> original)
M.toggle_window = function()
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

return M
