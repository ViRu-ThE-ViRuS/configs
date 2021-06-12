local symbol_config = require('utils').symbol_config

-- setup lsps
require('lsp-setup')

-- setup custom handlers
require('lsp-setup/handlers')

-- custom signs
vim.fn.sign_define("LspDiagnosticsSignError", {text = symbol_config['sign_error'] })
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = symbol_config['sign_warning'] })
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = symbol_config['sign_info'] })
vim.fn.sign_define("LspDiagnosticsSignHint", {text = symbol_config['sign_hint'] })

