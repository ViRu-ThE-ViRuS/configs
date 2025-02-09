return {
  'neovim/nvim-lspconfig',
  dependencies = {
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    { 'jayp0521/mason-null-ls.nvim',     dependencies = "nvimtools/none-ls.nvim" },

    'ray-x/lsp_signature.nvim',
    { 'creativenull/efmls-configs-nvim', dependencies = 'neovim/nvim-lspconfig' },
  },
  event = 'BufReadPre',
  config = function()
    -- use mason to install dependencies
    require('mason').setup({ ui = { border = 'rounded' } })
    require('mason-lspconfig').setup({ ensure_installed = { 'pyright', 'clangd', 'lua_ls', 'efm' } })
    require('mason-null-ls').setup({
      ensure_installed = { 'autopep8', 'prettier', 'cpplint' },
      automatic_installation = true
    })

    -- setup lsps
    require("lsp-setup/init")

    -- setup handlers
    require("lsp-setup/handlers")

    -- reloading config often leaves hanging diagnostics
    local symbols = session.config.symbols
    vim.diagnostic.reset()
    vim.diagnostic.config({
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = symbols.sign_error,
          [vim.diagnostic.severity.WARN] = symbols.sign_warning,
          [vim.diagnostic.severity.INFO] = symbols.sign_info,
          [vim.diagnostic.severity.HINT] = symbols.sign_hint,
        },
        texthl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticError",
          [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
          [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
          [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        },
        numhl = {
          [vim.diagnostic.severity.ERROR] = "DiagnosticError",
          [vim.diagnostic.severity.WARN] = "DiagnosticWarn",
          [vim.diagnostic.severity.INFO] = "DiagnosticInfo",
          [vim.diagnostic.severity.HINT] = "DiagnosticHint",
        }
      },
      virtual_text = { spacing = 4 },
      virtual_lines = false,
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
  end,
}
