-- wrap func(arg) + fugitive refresh
local function wrap_refresh_fugitive(func, arg)
  return function()
    local ret_val = func(arg)
    local current_window = vim.api.nvim_get_current_win()

    vim.cmd(string.format(
      'windo if &ft == "fugitive" | :edit | end | call win_gotoid(%s)',
      current_window
    ))

    -- vim.schedule_wrap(vim.api.nvim_set_current_win, current_window)
    -- vim.fn.win_gotoid(current_window)
    return ret_val
  end
end

return {
  'lewis6991/gitsigns.nvim',
  event = 'BufReadPre',
  config = function()
    local utils = require('utils')
    local gitsigns = require('gitsigns')

    gitsigns.setup {
      numhl = false,
      linehl = false,
      preview_config = { border = 'rounded' },
      on_attach = function(bufnr)
        local map_opts = { silent = true, buffer = bufnr }

        -- hunk navigation
        utils.map('n', '[c', gitsigns.prev_hunk, map_opts)
        utils.map('n', ']c', gitsigns.next_hunk, map_opts)

        -- text objects
        utils.map({ 'o', 'x' }, 'ig', gitsigns.select_hunk, map_opts)
        utils.map({ 'o', 'x' }, 'ag', gitsigns.select_hunk, map_opts)

        -- keymaps
        utils.map('n', '<leader>gp', gitsigns.preview_hunk, map_opts)
        utils.map('n', '<leader>gt', gitsigns.toggle_deleted, map_opts)

        -- reset hunk
        utils.map('n', '<leader>gr', gitsigns.reset_hunk, map_opts)
        utils.map('v', '<leader>gr', function() gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, map_opts)

        -- stage and refresh fugitive
        utils.map('n', '<leader>gs', wrap_refresh_fugitive(gitsigns.stage_hunk), map_opts)
        utils.map('v', '<leader>gs', wrap_refresh_fugitive(gitsigns.stage_hunk, { vim.fn.line('.'), vim.fn.line('v') }),
          map_opts)

        -- unstage and refresh fugitive
        utils.map('n', '<leader>gu', wrap_refresh_fugitive(gitsigns.undo_stage_hunk), map_opts)
        utils.map('v', '<leader>gu',
          wrap_refresh_fugitive(gitsigns.undo_stage_hunk, { vim.fn.line('.'), vim.fn.line('v') }), map_opts)
      end
    }
  end
}
