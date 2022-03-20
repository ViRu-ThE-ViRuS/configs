local utils = require('utils')
local notify = require('notify')
local harpoo_ui = require('harpoon/ui')

local function notify_forward(message, callback, ...)
    local arg = ...

    return function()
        notify(message, 'info', { render = 'minimal' })
        callback(arg)
    end
end

-- vim.g.harpoon_log_level = 'debug'

utils.map('n', '<leader>tA', notify_forward('harpoon set', require('harpoon.mark').add_file))
utils.map('n', '<leader>ta', harpoo_ui.toggle_quick_menu)
utils.map('n', '<leader>tq', function() harpoo_ui.nav_file(1) end)
utils.map('n', '<leader>tw', function() harpoo_ui.nav_file(2) end)
utils.map('n', '<leader>te', function() harpoo_ui.nav_file(3) end)
utils.map('n', '<leader>tr', function() harpoo_ui.nav_file(4) end)
