return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason-lspconfig.nvim',
        'jayp0521/mason-null-ls.nvim',
        'jay-babu/mason-nvim-dap.nvim',

        'jose-elias-alvarez/null-ls.nvim',
        'ray-x/lsp_signature.nvim',
    },
    event = 'BufReadPost',
    config = function()
        -- use mason to install dependencies
        require('mason').setup({ ui = { border = 'rounded' } })
        require('mason-lspconfig').setup({ ensure_installed = { 'pyright', 'clangd', 'sumneko_lua', 'tsserver' } })
        require('mason-null-ls').setup({ ensure_installed = { 'cppcheck', 'autopep8', 'prettier' } })

        -- setup lsps
        require("lsp-setup/init")

        -- setup handlers and extensions
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

        --- @format disable
        local symbol_config = require("utils").editor_config.symbol_config
        vim.fn.sign_define("DiagnosticSignError", { text = symbol_config.sign_error, texthl = "DiagnosticError", numhl = "DiagnosticError" })
        vim.fn.sign_define("DiagnosticSignWarn", { text = symbol_config.sign_warning, texthl = "DiagnosticWarn", numhl = "DiagnosticWarn" })
        vim.fn.sign_define("DiagnosticSignInfo", { text = symbol_config.sign_info, texthl = "DiagnosticInfo", numhl = "DiagnosticInfo" })
        vim.fn.sign_define("DiagnosticSignHint", { text = symbol_config.sign_hint, texthl = "DiagnosticHint", numhl = "DiagnosticHint" })
    end,
}
