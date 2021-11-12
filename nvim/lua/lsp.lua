local symbol_config = require("utils").symbol_config

-- setup lsps
require("lsp-setup")

-- setup custom handlers
require("lsp-setup/handlers")

-- custom signs
vim.fn.sign_define("DiagnosticSignError", {text = symbol_config.sign_error, texthl = "VirtualTextError", numhl = "VirtualTextError"})
vim.fn.sign_define("DiagnosticSignWarn", {text = symbol_config.sign_warning, texthl = "VirtualTextWarning", numhl = "VirtualTextWarning"})
vim.fn.sign_define("DiagnosticSignInfo", {text = symbol_config.sign_info, texthl = "VirtualTextInfo", numhl = "VirtualTextInfo"})
vim.fn.sign_define("DiagnosticSignHint", {text = symbol_config.sign_hint, texthl = "VirtualTextHint", numhl = "VirtualTextHint"})

