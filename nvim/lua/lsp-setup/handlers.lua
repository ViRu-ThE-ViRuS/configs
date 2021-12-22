-- custom diagnostics display
vim.lsp.handlers["textDocument/publishDiagnostics"] =
    vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics,
    {
        signs = true,
        virtual_text = {spacing = 4},
        update_in_insert = true,
        underline = false
    }
)

-- bordered markdown hover
vim.lsp.handlers["textDocument/hover"] = function(err, result)
    if err or not (result and result.contents) then
        return
    end

    local lines = result.contents.value
    local kind = result.contents.kind

    if kind == "markdown" then
        lines = vim.lsp.util.convert_input_to_markdown_lines(lines)
    end

    vim.lsp.util.open_floating_preview(lines, kind, {border = "rounded", focusable = false})
end

-- markdown render hover text
-- now using lsp-signature
-- vim.lsp.handlers["textDocument/signatureHelp"] = function(_, _, result)
--     if not (result and result.signatures and result.signatures[1]) then
--         return
--     end

--     local lines = vim.lsp.util.trim_empty_lines(vim.lsp.util.convert_signature_help_to_markdown_lines(result))
--     if vim.tbl_isempty(lines) then
--         return
--     end

--     vim.lsp.util.open_floating_preview(
--         lines,
--         vim.lsp.util.try_trim_markdown_code_blocks(lines),
--         {border = "rounded", focusable = false}
--     )
-- end

-- keep preview window open
-- vim.lsp.util.close_preview_autocmd = function(events, winnr)
--     events = vim.tbl_filter(function(v) return v ~= 'CursorMovedI' and v ~= 'BufLeave' end, events)
--     local autocommand  = 'autocmd ' .. table.concat(events, ',') .. ' <buffer> ++once lua pcall(vim.api.nvim_win_close, ' .. winnr .. ', true)'
--     vim.cmd(autocommand)
-- end

-- custom qf_rename
local qf_rename = function()
    local position_params = vim.lsp.util.make_position_params()
    position_params.newName = vim.fn.input("Rename To> ", vim.fn.expand("<cword>"))

    vim.lsp.buf_request(0, "textDocument/rename", position_params,
        function(err, result, ...)
            if not result.changes then
                return
            end

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
                    table.insert( entries, {bufnr = bufnr, lnum = start_line, col = edit.range.start.character + 1, text = line})
                end
            end

            if num_files > 1 then
                require("utils").qf_populate(entries, "r")
            end

            print(string.format("Updated %d instance(s) in %d file(s)", num_updates, num_files))
        end
    )
end
vim.lsp.buf.rename = qf_rename
