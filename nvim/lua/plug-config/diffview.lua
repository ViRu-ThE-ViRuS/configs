-- toggle diffopt linematch:50
local function toggle_line_matching()
  local current_diffopt = vim.api.nvim_get_option_value('diffopt', { scope = 'local' })
  local linematch = 'linematch:50'

  if string.match(current_diffopt, linematch) then
    vim.opt.diffopt = vim.opt.diffopt - linematch
    require('utils').notify("linematch", "debug", { title = '[UI] deactivated', render = "compact" })
  else
    vim.opt.diffopt = vim.opt.diffopt + linematch
    require('utils').notify("linematch", "info", { title = '[UI] activated', render = "compact" })
  end
end

return {
  'sindrets/diffview.nvim',
  cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
  init = function()
    local utils = require("utils")
    utils.map("n", "<leader>gh", "<cmd>DiffviewOpen<cr>")
    utils.map("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>")
    utils.map("n", "<leader>gl", "<cmd>DiffviewFileHistory .<cr>")

    local statusline = require('statusline')
    vim.api.nvim_create_autocmd('FileType', {
      group = statusline.autocmd_group,
      pattern = 'DiffviewFiles',
      callback = statusline.set_statusline_func('DiffViewFiles', true),
    })
    vim.api.nvim_create_autocmd('FileType', {
      group = statusline.autocmd_group,
      pattern = 'DiffviewFileHistory',
      callback = statusline.set_statusline_func('DiffViewFileHistory', true),
    })
  end,
  config = function()
    local actions = require("diffview/actions")

    require("diffview").setup({
      file_panel = { win_config = { position = "right" }, listing_style = "list" },
      key_bindings = {
        disable_defaults = true,
        view = {
          ["]q"] = actions.select_next_entry,
          ["[q"] = actions.select_prev_entry,

          ["e"] = actions.goto_file,
          ["<leader>gh"] = actions.toggle_files,

          -- merge tool
          ['<m-2>'] = actions.conflict_choose('ours'),
          ['<m-3>'] = actions.conflict_choose('theirs'),
          ['<m-0>'] = actions.conflict_choose('base'),
          ['<m-a>'] = actions.conflict_choose('all'),
          ['<m-x>'] = actions.conflict_choose('none'),
          ['<m-l>'] = actions.cycle_layout,
          ["[x"] = actions.prev_conflict,
          ["]x"] = actions.next_conflict,

          ['<tab>'] = toggle_line_matching
        },
        file_panel = {
          ["j"] = actions.next_entry,
          ["k"] = actions.prev_entry,
          ["<cr>"] = actions.select_entry,

          ["]q"] = actions.select_next_entry,
          ["[q"] = actions.select_prev_entry,
          ["]c"] = actions.select_next_entry,
          ["[c"] = actions.select_prev_entry,

          ["s"] = actions.toggle_stage_entry,
          ["u"] = actions.toggle_stage_entry,
          ["S"] = actions.stage_all,
          ["U"] = actions.unstage_all,
          ["X"] = actions.restore_entry,
          ["R"] = actions.refresh_files,

          ["e"] = actions.goto_file,
          ["<leader>gh"] = actions.toggle_files,

          -- NOTE(vir): fugitive integration
          ['cc'] = function()
            vim.cmd [[
              G
              G commit
            ]]
          end,

          ['<tab>'] = toggle_line_matching
        },
        file_history_panel = {
          ["zr"] = actions.open_all_folds,
          ["zm"] = actions.close_all_folds,

          ["]q"] = actions.select_next_entry,
          ["[q"] = actions.select_prev_entry,
          ["]c"] = actions.select_next_entry,
          ["[c"] = actions.select_prev_entry,

          ["j"] = actions.next_entry,
          ["k"] = actions.prev_entry,
          ["<cr>"] = actions.select_entry,
          ["="] = actions.open_in_diffview,

          ["e"] = actions.goto_file,
          ["<leader>gh"] = actions.toggle_files,

          ['<tab>'] = toggle_line_matching
        },
        options_panel = {},
      },
    })
  end
}
