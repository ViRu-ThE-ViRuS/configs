-- diagnostics display
vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = true,
        virtual_text = {spacing = 4},
        update_in_insert = true,
        underline = false
    })

-- bordered hover
vim.lsp.handlers['textDocument/hover'] =
    vim.lsp.with(vim.lsp.handlers.hover, {
        border = 'rounded',
        focusable = false
    })

-- populate qf list with changes (if multiple files modified)
local qf_rename = function()
    local position_params = vim.lsp.util.make_position_params()
    position_params.newName = vim.fn.input("Rename To> ", vim.fn.expand("<cword>"))

    vim.lsp.buf_request(0, "textDocument/rename", position_params, function(err, result, ...)
        if not result.changes then return end
        vim.lsp.handlers["textDocument/rename"](err, result, ...)

        local entries = {}
        local num_files = 0
        local num_updates = 0
        for uri, edits in pairs(result.changes) do
            num_files = num_files + 1
            local bufnr = vim.uri_to_bufnr(uri)

            for _, edit in ipairs(edits) do
                local start_line = edit.range.start.line + 1
                local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]

                num_updates = num_updates + 1
                table.insert(entries, {
                    bufnr = bufnr,
                    lnum = start_line,
                    col = edit.range.start.character + 1,
                    text = line
                })
            end
        end

        if num_files > 1 then require("utils").qf_populate(entries, "r") end
        print(string.format("Updated %d instance(s) in %d file(s)", num_updates, num_files))
    end)
end
vim.lsp.buf.rename = qf_rename
