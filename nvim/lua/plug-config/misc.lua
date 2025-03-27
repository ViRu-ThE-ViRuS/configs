local utils = require('utils')

return {
  {
    'famiu/bufdelete.nvim',
    init = function()
      utils.map("n", "<leader>q", function() require('bufdelete').bufdelete(0, true) end)
    end,
  },

  {
    'tpope/vim-fugitive',
    cmd = { 'G', 'Gread', 'GcLog' },
    init = function()
      utils.map("n", "<leader>gD", function() vim.cmd.G({ bang = true, args = { 'difftool' } }) end)

      local statusline = require('statusline')
      vim.api.nvim_create_autocmd('FileType', {
        group = statusline.autocmd_group,
        pattern = { 'fugitive', 'git' },
        callback = statusline.set_statusline_func('Git'),
      })
      vim.api.nvim_create_autocmd('FileType', {
        group = statusline.autocmd_group,
        pattern = 'gitcommit',
        callback = statusline.set_statusline_func('GitCommit'),
      })

      -- disable line numbers in git status
      vim.api.nvim_create_autocmd('FileType', {
        group = 'Misc',
        pattern = 'fugitive',
        command = 'set nonumber'
      })
    end
  },

  {
    'tommcdo/vim-exchange',
    keys = { 'sl', 'sL', 'sl/' },
    init = function() vim.g.exchange_no_mappings = true end,
    config = function()
      utils.map({ 'n', 'v' }, 'sl', '<plug>(Exchange)')
      utils.map('n', 'sL', '<plug>(ExchangeLine)')
      utils.map('n', 'sl/', '<plug>(ExchangeClear)')
    end
  },

  {
    'godlygeek/tabular',
    cmd = 'Tabularize',
    init = function() utils.map("v", "<leader>=", ":Tab /") end,
  },

  {
    'tpope/vim-eunuch',
    cmd = { 'Delete', 'Rename', 'Chmod' },
  },

  {
    'tweekmonster/startuptime.vim',
    cmd = 'StartupTime',
  },

  {
    'MeanderingProgrammer/render-markdown.nvim',
    opts = { file_types = { "markdown", "Avante", "copilot-chat" } },
    ft = { "markdown", "Avante", "copilot-chat" },
  },
}
