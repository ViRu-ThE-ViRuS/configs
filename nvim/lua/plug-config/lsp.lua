return {
  -- nvim-lspconfig provides server configurations for vim.lsp.config()
  {
    'neovim/nvim-lspconfig',
    lazy = false,
    priority = 1000,
  },

  -- Mason for installing language servers
  {
    'williamboman/mason.nvim',
    dependencies = { 'neovim/nvim-lspconfig' },
    lazy = false,
    priority = 950,
    config = function()
      require('mason').setup({ ui = { border = 'rounded' } })
    end,
  },

  -- Mason LSP config bridge - for automatic installation
  {
    'williamboman/mason-lspconfig.nvim',
    dependencies = { 'williamboman/mason.nvim' },
    lazy = false,
    priority = 900,
    config = function()
      require('mason-lspconfig').setup({
        ensure_installed = { 'pyright', 'clangd', 'lua_ls', 'efm' },
        automatic_installation = true,
      })
    end,
  },

  -- LSP signature hints
  {
    'ray-x/lsp_signature.nvim',
    lazy = false,
  },

  -- EFM configs for formatters/linters
  {
    'creativenull/efmls-configs-nvim',
    lazy = false,
  },

  -- null-ls / none-ls setup and main LSP configuration
  {
    'nvimtools/none-ls.nvim',
    dependencies = {
      'williamboman/mason.nvim',
      'williamboman/mason-lspconfig.nvim',
      { 'jayp0521/mason-null-ls.nvim' },
      'ray-x/lsp_signature.nvim',
      'creativenull/efmls-configs-nvim',
    },
    event = 'BufReadPre',
    config = function()
      require('mason-null-ls').setup({
        ensure_installed = { 'autopep8', 'prettier', 'cpplint' },
        automatic_installation = true
      })

      -- setup lsps using built-in vim.lsp.config() and vim.lsp.enable()
      require("lsp-setup/init")

      -- setup custom LSP handlers
      require("lsp-setup/handlers")

      -- configure diagnostics
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
  },
}
