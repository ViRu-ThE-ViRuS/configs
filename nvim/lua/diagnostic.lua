-- NOTE(vir): reloading config often leaves hanging diagnostics
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

-- custom signs
local symbol_config = require("utils").editor_config.symbol_config
vim.fn.sign_define("DiagnosticSignError", { text = symbol_config.sign_error, texthl = "DiagnosticError", numhl = "DiagnosticError"})
vim.fn.sign_define("DiagnosticSignWarn", { text = symbol_config.sign_warning, texthl = "DiagnosticWarn", numhl = "DiagnosticWarn"})
vim.fn.sign_define("DiagnosticSignInfo", { text = symbol_config.sign_info, texthl = "DiagnosticInfo", numhl = "DiagnosticInfo"})
vim.fn.sign_define("DiagnosticSignHint", { text = symbol_config.sign_hint, texthl = "DiagnosticHint", numhl = "DiagnosticHint"})

