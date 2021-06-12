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

vim.lsp.handlers['textDocument/signatureHelp'] = function (_, _, result)
    if not (result and result.signatures and result.signatures[1]) then
        return nil
    end

    local lines = vim.lsp.util.trim_empty_lines(vim.lsp.util.convert_signature_help_to_markdown_lines(result))
    if lines == nil or vim.tbl_isempty(lines) then
        return nil
    end

    vim.lsp.util.open_floating_preview(lines, vim.lsp.util.try_trim_markdown_code_blocks(lines),
                                       {border='single', focusable=false})
end

