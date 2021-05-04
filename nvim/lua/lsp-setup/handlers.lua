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

-- local lsputil = require('lsputil')
-- vim.lsp.handlers['textDocument/codeAction'] = lsputil.codeAction.code_action_handler
-- vim.lsp.handlers['textDocument/references'] = lsputil.locations.references_handler
-- vim.lsp.handlers['textDocument/definition'] = lsputil.locations.definition_handler
-- vim.lsp.handlers['textDocument/declaration'] = lsputil.locations.declaration_handler
-- vim.lsp.handlers['textDocument/typeDefinition'] = lsputil.locations.typeDefinition_handler
-- vim.lsp.handlers['textDocument/implementation'] = lsputil.locations.implementation_handler
-- vim.lsp.handlers['textDocument/documentSymbol'] = lsputil.symbols.document_handler
-- vim.lsp.handlers['workspace/symbol'] = lsputil.symbols.workspace_handler
