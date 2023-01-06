-- refresh fugitive window if present
local function refresh_fugitive()
    local current_window = vim.api.nvim_get_current_win()
    vim.cmd [[ windo if &ft == 'fugitive' | :edit | end ]]
    vim.api.nvim_set_current_win(current_window)
end

return {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPost',
    config = function()
        local utils = require('utils')
        local gitsigns = require('gitsigns')

        gitsigns.setup {
            numhl = false,
            linehl = false,
            preview_config = { border = 'rounded' },
            on_attach = function(bufnr)
                -- hunk navigation
                utils.map('n', '[c', gitsigns.prev_hunk, { silent = true, buffer = bufnr })
                utils.map('n', ']c', gitsigns.next_hunk, { silent = true, buffer = bufnr })

                -- text objects
                utils.map({ 'o', 'x' }, 'ig', gitsigns.select_hunk, { silent = true, buffer = bufnr })
                utils.map({ 'o', 'x' }, 'ag', gitsigns.select_hunk, { silent = true, buffer = bufnr })

                -- return a function, which calls func(arg) and refreshes fugitive
                local function wrap_refresh_fugitive(func, arg)
                    return function()
                        local ret_val = func(arg)
                        vim.schedule(refresh_fugitive)
                        return ret_val
                    end
                end

                --- @format disable
                -- keymaps
                utils.map('n', '<leader>gp', gitsigns.preview_hunk, { silent = true, buffer = bufnr })
                utils.map('n', '<leader>gt', gitsigns.toggle_deleted, { silent = true, buffer = bufnr })

                -- reset hunk
                utils.map('n', '<leader>gr', gitsigns.reset_hunk, { silent = true, buffer = bufnr })
                utils.map('v', '<leader>gr', function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { silent = true, buffer = bufnr })

                -- stage and refresh fugitive
                utils.map('n', '<leader>gs', wrap_refresh_fugitive(gitsigns.stage_hunk), { silent = true, buffer = bufnr })
                utils.map('v', '<leader>gs', wrap_refresh_fugitive(gitsigns.stage_hunk, { vim.fn.line('.'), vim.fn.line('v') }), { silent = true, buffer = bufnr })

                -- unstage and refresh fugitive
                utils.map('n', '<leader>gu', wrap_refresh_fugitive(gitsigns.undo_stage_hunk), { silent = true, buffer = bufnr })
                utils.map('v', '<leader>gu', wrap_refresh_fugitive(gitsigns.undo_stage_hunk, { vim.fn.line('.'), vim.fn.line('v') }), { silent = true, buffer = bufnr })
            end
        }
    end
}
