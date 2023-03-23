return {
  'liuchengxu/vista.vim',
  cmd = { 'Vista' },
  init = function()
    local utils = require('utils')

    utils.map('n', '<leader>k', function() vim.cmd.Vista({ bang = true, args = { '!' } }) end)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'vista', 'vista_kind' },
      callback = function()
        utils.map('n', '<c-o>', '<cmd>wincmd p<cr>', { buffer = 0 })
        require('statusline').set_statusline_func('Outline')()
      end
    })
  end,
  config = function()
    local lsp_icons = require('lsp-setup/lsp_utils').lsp_icons

    local vista_icons = {}
    for key, value in pairs(lsp_icons) do
      vista_icons[(key:gsub("^%u", string.lower))] = value.icon
    end

    vim.g['vista#renderer#icons '] = vista_icons
    vim.g.vista_icon_indent = { "-> ", "-> " }
    vim.g.vista_fold_toggle_icons = { ">", "$" }
    vim.g.vista_fzf_preview = { 'right:50%' }
    vim.g.vista_disable_statusline = true
    -- vim.g.vista_default_executive = 'nvim_lsp'
  end
}
