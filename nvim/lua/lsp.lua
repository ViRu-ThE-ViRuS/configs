-- lazy loading, reload current file
vim.defer_fn(function()
    vim.cmd [[ if &ft == 'packer' |  | else | silent! e % ]]
end, 0)

-- setup lsps
require("lsp-setup/init")

-- setup handlers and extensions
require("lsp-setup/handlers")

-- setup diagnostic
require('diagnostic')
