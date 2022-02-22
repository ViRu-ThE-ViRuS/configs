-- lazy loading, reload current file
vim.defer_fn(function()
    vim.cmd [[ if &ft == 'packer' |  | else | silent! e % ]]
end, 0)

-- setup lsps
require("lsp-setup/init")

-- setup handlers and extensions (deferred)
require("lsp-setup/handlers")
require("lsp_signature").setup({
    doc_lines = 3,
    hint_prefix = "<>",
    handler_opts = {border = 'rounded'}
})

-- custom signs
local symbol_config = require("utils").symbol_config
vim.fn.sign_define("DiagnosticSignError", { text = symbol_config.sign_error, texthl = "VirtualTextError", numhl = "VirtualTextError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = symbol_config.sign_warning, texthl = "VirtualTextWarning", numhl = "VirtualTextWarning" })
vim.fn.sign_define("DiagnosticSignInfo", { text = symbol_config.sign_info, texthl = "VirtualTextInfo", numhl = "VirtualTextInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = symbol_config.sign_hint, texthl = "VirtualTextHint", numhl = "VirtualTextHint" })
