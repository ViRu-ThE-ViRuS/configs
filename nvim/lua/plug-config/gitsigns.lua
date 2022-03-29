local utils = require('utils')
local gitsigns = require('gitsigns')

-- TODO(vir): update fugitive(ifopen) on stage/unstage/reset
require('gitsigns').setup {
    numhl = false,
    linehl = false,
    preview_config = {border = 'rounded'},
    on_attach = function(buffer_nr)
        utils.map('n', ']c', function()
            if vim.wo.diff then
                return ']c'
            end

            vim.schedule(function() gitsigns.next_hunk() end)
            return '<Ignore>'
        end, {expr = true, silent = true}, buffer_nr)

        utils.map('n', '[c', function()
            if vim.wo.diff then
                return '[c'
            end

            vim.schedule(function() gitsigns.prev_hunk() end)
            return '<Ignore>'
        end, {expr = true, silent = true}, buffer_nr)


        utils.map({'n', 'v'}, '<leader>gs', '<cmd>Gitsigns stage_hunk<cr>', {silent=true}, buffer_nr)
        utils.map({'n', 'v'}, '<leader>gr', '<cmd>Gitsigns reset_hunk<cr>', {silent=true}, buffer_nr)
        utils.map('n', '<leader>gu', gitsigns.undo_stage_hunk, {silent=true}, buffer_nr)
        utils.map('n', '<leader>gp', gitsigns.preview_hunk, {silent=true}, buffer_nr)
        utils.map('n', '<leader>gt', gitsigns.toggle_deleted, {silent=true}, buffer_nr)

        utils.map({'o', 'x'}, 'ig', gitsigns.select_hunk, {silent=true}, buffer_nr)
        utils.map({'o', 'x'}, 'ag', gitsigns.select_hunk, {silent=true}, buffer_nr)
    end
}
