-- state, keep track of window ids
local state = {}

-- toggle current window (maximum <-> original)
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

return {toggle_window = toggle_window}
