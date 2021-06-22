vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = true,
        virtual_text = { spacing = 4 },
        update_in_insert = true
    }
)

vim.lsp.handlers['textDocument/definition'] = function(_, _, result)
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

vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
    vim.lsp.handlers.hover, { border = 'single', focusable=false })

vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
    vim.lsp.handlers.signature_help, { border = 'single', focusable=false })

