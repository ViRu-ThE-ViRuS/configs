-- NOTE(vir): references to fugitive and diffview
-- refresh fugitive window
local function gitsigns_post_refresh_fugitive()
  local diffview_buf = nil
  local fugitive_buf = nil

  for _, winid in pairs(vim.api.nvim_tabpage_list_wins(0)) do
    local buf = vim.api.nvim_win_get_buf(winid)

    fugitive_buf = fugitive_buf or (vim.api.nvim_buf_get_option(buf, 'filetype') == "fugitive" and buf)
    diffview_buf = diffview_buf or (string.find(vim.api.nvim_buf_get_name(buf), '^diffview://') ~= nil)

    -- early exit if both found already
    if fugitive_buf and diffview_buf then break end
  end

  -- do not update fugitive when in diffview tab
  if fugitive_buf and not diffview_buf then
    vim.defer_fn(require('lib/core').partial(
      vim.api.nvim_buf_call,
      fugitive_buf,
      vim.cmd.edit
    ), 10)
  end
end

-- wrap func(arg) + fugitive window referesh
local function wrap_refresh_fugitive(func)
  return function()
    local ret_val = func()
    gitsigns_post_refresh_fugitive()
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
        -- NOTE(vir): no need to refresh fugitive as we dont write buffer after reset
        utils.map('n', '<leader>gr', gitsigns.reset_hunk, map_opts)
        utils.map('x', '<leader>gr', ':Gitsigns reset_hunk<cr>', map_opts)

        -- stage and refresh fugitive
        utils.map('n', '<leader>gs', wrap_refresh_fugitive(gitsigns.stage_hunk), map_opts)
        utils.map('x', '<leader>gs',
          ':Gitsigns stage_hunk<cr><cmd>lua require("plug-config/gitsigns").module_exports.gitsigns_post_refresh_fugitive()<cr>',
          map_opts)

        -- unstage and refresh fugitive
        -- NOTE(vir): gitsigns undo_stage_hunk doesnt support partial-hunks
        utils.map('n', '<leader>gu', wrap_refresh_fugitive(gitsigns.undo_stage_hunk), map_opts)
      end
    }
  end,

  -- export usage of this plugin
  module_exports = {
    gitsigns_post_refresh_fugitive = gitsigns_post_refresh_fugitive
  }
}
