vim.diagnostic.config({
    signs = true,
    virtual_text = {spacing = 4},
    update_in_insert = true,
    underline = false,
    float = {
        prefix = '',
        header = '',
        source = 'always',
        border = 'rounded',
        focusable = false
    }
})

-- custom signs
local symbol_config = require("utils").symbol_config
vim.fn.sign_define("DiagnosticSignError", { text = symbol_config.sign_error, texthl = "VirtualTextError", numhl = "VirtualTextError" })
vim.fn.sign_define("DiagnosticSignWarn", { text = symbol_config.sign_warning, texthl = "VirtualTextWarning", numhl = "VirtualTextWarning" })
vim.fn.sign_define("DiagnosticSignInfo", { text = symbol_config.sign_info, texthl = "VirtualTextInfo", numhl = "VirtualTextInfo" })
vim.fn.sign_define("DiagnosticSignHint", { text = symbol_config.sign_hint, texthl = "VirtualTextHint", numhl = "VirtualTextHint" })
