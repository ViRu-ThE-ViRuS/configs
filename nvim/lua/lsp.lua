-- lazy loading, trigger lsp
vim.defer_fn(function() vim.cmd [[ if &ft == 'packer' |  | else | silent! e % ]] end, 0)

-- install dependencies
require('mason').setup()
require('mason-lspconfig').setup({ ensure_installed = { 'pyright', 'clangd', 'sumneko_lua', 'tsserver' } })
require('mason-null-ls').setup({ ensure_installed = { 'cppcheck', 'autopep8', 'prettier' } })

-- setup lsps
require("lsp-setup/init")

-- setup handlers and extensions
require("lsp-setup/handlers")

-- setup diagnostic
require('diagnostic')
