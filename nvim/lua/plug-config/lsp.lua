return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    'jayp0521/mason-null-ls.nvim',

    'jose-elias-alvarez/null-ls.nvim',
    'ray-x/lsp_signature.nvim',
  },
  event = 'BufReadPre',
  config = function()
    -- use mason to install dependencies
    require('mason').setup({ ui = { border = 'rounded' } })
    require('mason-lspconfig').setup({ ensure_installed = { 'pyright', 'clangd', 'lua_ls', 'tsserver' } })
    require('mason-null-ls').setup({
      ensure_installed = { 'cppcheck', 'autopep8', 'prettier', 'cpplint' },
      automatic_installation = true
    })

    -- setup lsps
    require("lsp-setup/init")

    -- setup handlers
    require("lsp-setup/handlers")

    -- reloading config often leaves hanging diagnostics
    vim.diagnostic.reset()
    vim.diagnostic.config({
      signs = true,
      virtual_text = { spacing = 4 },
      update_in_insert = true,
      underline = true,
      severity_sort = false,
      float = {
        prefix = '',
        header = '',
        source = 'always',
        border = 'rounded',
        focusable = false
      }
    })

    local symbols = session.config.symbols
    vim.fn.sign_define("DiagnosticSignError",
      { text = symbols.sign_error, texthl = "DiagnosticError", numhl = "DiagnosticError" })
    vim.fn.sign_define("DiagnosticSignWarn",
      { text = symbols.sign_warning, texthl = "DiagnosticWarn", numhl = "DiagnosticWarn" })
    vim.fn.sign_define("DiagnosticSignInfo",
      { text = symbols.sign_info, texthl = "DiagnosticInfo", numhl = "DiagnosticInfo" })
    vim.fn.sign_define("DiagnosticSignHint",
      { text = symbols.sign_hint, texthl = "DiagnosticHint", numhl = "DiagnosticHint" })
  end,
}
