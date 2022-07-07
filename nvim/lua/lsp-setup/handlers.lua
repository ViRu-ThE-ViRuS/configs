local utils = load('utils')

-- bordered hover
vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(vim.lsp.handlers.hover, {border = 'rounded', focusable = false})

-- populate qf list with changes (if multiple files modified)
local function qf_rename()
    local position_params = vim.lsp.util.make_position_params()
    position_params.oldName = vim.fn.expand("<cword>")

    vim.ui.input({prompt = 'Rename To> ', default = position_params.oldName}, function(input)
        if input == nil then
            utils.notify('[lsp] aborted rename', 'warn', {render = 'minimal'}, true)
            return
        end

        position_params.newName = input
        vim.lsp.buf_request(0, "textDocument/rename", position_params, function(err, result, ...)
            if not result or (not result.documentChanges and not result.changes) then
                utils.notify('could not perform rename', 'error', {
                    title = string.format('[lsp] rename: %s -> %s', position_params.oldName, position_params.newName),
                    timeout = 500
                }, true)

                return
            end

            vim.lsp.handlers["textDocument/rename"](err, result, ...)

            local notification, entries = '', {}
            local num_files, num_updates = 0, 0

            if result.documentChanges then
                for _, document in pairs(result.documentChanges) do
                    num_files = num_files + 1
                    local uri = document.textDocument.uri
                    local bufnr = vim.uri_to_bufnr(uri)

                    for _, edit in ipairs(document.edits) do
                        local start_line = edit.range.start.line + 1
                        local line = vim.api.nvim_buf_get_lines(bufnr, start_line - 1, start_line, false)[1]

                        table.insert(entries, {
                            bufnr = bufnr,
                            lnum = start_line,
                            col = edit.range.start.character + 1,
                            text = line
                        })
                    end

                    local short_uri = string.sub(vim.uri_to_fname(uri), #vim.fn.getcwd() + 2)
                    notification = notification .. string.format('made %d change(s) in %s\n', #document.edits, short_uri)

                    num_updates = num_updates + #document.edits
                end
            end

            if result.changes then
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

                    local short_uri = string.sub(vim.uri_to_fname(uri), #vim.fn.getcwd() + 2)
                    notification = notification .. string.format('made %d change(s) in %s\n', #edits, short_uri)
                end
            end

            utils.notify(notification:sub(1, -2), 'info', {
                title = string.format('[lsp] rename: %s -> %s', position_params.oldName, position_params.newName),
                timeout = 2500
            }, true)

            if num_files > 1 then utils.qf_populate(entries, "r") end
        end)
    end)
end
vim.lsp.buf.rename = qf_rename
