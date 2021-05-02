local symbol_config = require('utils').symbol_config

-- setup lsps
require('lsp-setup')

-- custom handlers
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = true,
        virtual_text = { spacing = 4 },
        update_in_insert = true
    }
)

vim.lsp.handlers["textDocument/definition"] = function(_, _, result)
    if not result or vim.tbl_isempty(result) then
        print("[LSP] No definition found...")
        return
    end

    if vim.tbl_islist(result) then
        vim.lsp.util.jump_to_location(result[1])
    else
        vim.lsp.util.jump_to_location(result)
    end
end

-- custom signs
vim.fn.sign_define("LspDiagnosticsSignError", {text = symbol_config['sign_error'] })
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = symbol_config['sign_warning'] })
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = symbol_config['sign_info'] })
vim.fn.sign_define("LspDiagnosticsSignHint", {text = symbol_config['sign_hint'] })

