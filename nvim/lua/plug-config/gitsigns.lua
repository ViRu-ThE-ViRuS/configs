-- refresh fugitive window if present
local function refresh_fugitive()
    local current_window = vim.api.nvim_get_current_win()
    vim.cmd [[ windo if &ft == 'fugitive' | :edit | end ]]
    vim.api.nvim_set_current_win(current_window)
end

return {
    'lewis6991/gitsigns.nvim',
    event = 'BufReadPost',
    config = {
        numhl = false,
        linehl = false,
        preview_config = { border = 'rounded' },
        on_attach = function(bufnr)
            local utils = require('utils')
            local gitsigns = require('gitsigns')

            -- hunk navigation
            utils.map('n', '[c', gitsigns.prev_hunk, { silent = true, buffer = bufnr })
            utils.map('n', ']c', gitsigns.next_hunk, { silent = true, buffer = bufnr })

            -- NOTE(vir): what are these for?
            -- utils.map('n', ']c', function()
            --     if vim.wo.diff then return ']c' end
            --     vim.schedule(gitsigns.next_hunk)
            --     return '<Ignore>'
            -- end, {expr = true, silent = true}, bufnr)

            -- utils.map('n', '[c', function()
            --     if vim.wo.diff then return '[c' end
            --     vim.schedule(gitsigns.prev_hunk)
            --     return '<Ignore>'
            -- end, {expr = true, silent = true}, bufnr)

            -- git actions
            utils.map('n', '<leader>gp', gitsigns.preview_hunk, { silent = true, buffer = bufnr })
            utils.map('n', '<leader>gt', gitsigns.toggle_deleted, { silent = true, buffer = bufnr })
            utils.map('n', '<leader>gr', gitsigns.reset_hunk, { silent = true, buffer = bufnr })

            utils.map('n', '<leader>gs', function()
                gitsigns.stage_hunk()
                vim.schedule(refresh_fugitive)
            end, { silent = true, buffer = bufnr })

            utils.map('n', '<leader>gu', function()
                gitsigns.undo_stage_hunk()
                vim.schedule(refresh_fugitive)
            end, { silent = true, buffer = bufnr })

            -- visual selection mappings
            utils.map('v', '<leader>gs', function()
                gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                vim.schedule(refresh_fugitive)
            end, { silent = true, buffer = bufnr })

            utils.map('v', '<leader>gu', function()
                gitsigns.undo_stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                vim.schedule(refresh_fugitive)
            end, { silent = true, buffer = bufnr })

            utils.map('v', '<leader>gr', function()
                gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
                vim.schedule(refresh_fugitive)
            end, { silent = true, buffer = bufnr })

            -- text objects
            utils.map({ 'o', 'x' }, 'ig', gitsigns.select_hunk, { silent = true, buffer = bufnr })
            utils.map({ 'o', 'x' }, 'ag', gitsigns.select_hunk, { silent = true, buffer = bufnr })
        end
    }
}
