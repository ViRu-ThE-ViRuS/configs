-- lazy loading, reload current file
vim.defer_fn(function()
    vim.cmd [[ if &ft == 'packer' |  | else | silent! e % ]]
end, 0)

-- setup lsps
load("lsp-setup/init")

-- setup handlers and extensions
load("lsp-setup/handlers")
require("lsp_signature").setup({
    doc_lines = 3,
    hint_prefix = "<>",
    handler_opts = {border = 'rounded'}
})

-- setup diagnostic
load('diagnostic')
