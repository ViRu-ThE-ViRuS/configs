return {
  'Dkendal/nvim-treeclimber',
  dependencies = { 'nvim-treesitter' },
  init = function()
    local utils = require('utils')

    utils.map('n', '<leader>uF', function()
      -- protect if no treesitter parser available
      local ft = vim.api.nvim_get_option_value('ft', { scope = 'local' })
      local bufnr = vim.api.nvim_get_current_buf()
      local valid, _ = pcall(vim.treesitter.get_parser, bufnr, ft)
      if not valid then return end

      require('nvim-treeclimber').show_control_flow()
    end)
  end
}
