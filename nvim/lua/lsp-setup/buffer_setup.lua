local utils = require('utils')
local setup_buffer = {}

local diagnostics_set = false

-- toggle quickfix list
ToggleDiagnosticsList = function()
    if not diagnostics_set then
        vim.lsp.diagnostic.set_loclist()
        diagnostics_set = true
        vim.cmd [[ wincmd p ]]
    else
        diagnostics_set = false
        vim.cmd [[ lclose ]]
    end
end

setup_buffer.setup_general_keymaps = function(buffer_nr)
	utils.map('n','<leader>d', '<cmd>lua vim.lsp.buf.definition()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>u', '<cmd>lua vim.lsp.buf.references()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>r','<cmd>lua vim.lsp.buf.rename()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<a-cr>', '<cmd>lua vim.lsp.buf.code_action()<cr>', { silent = true }, buffer_nr)
    utils.map('n','<c-f>', '<cmd>lua vim.lsp.buf.formatting()<cr>', { silent = true }, buffer_nr)
    utils.map('v','<c-f>', '<cmd>lua vim.lsp.buf.range_formatting()<cr>', { silent = true }, buffer_nr)
    utils.map('n','[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>', { silent = true }, buffer_nr)
    utils.map('n',']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>', { silent = true }, buffer_nr)

    utils.map('n', '<leader>e', '<cmd>lua ToggleDiagnosticsList()<cr>', { silent = true }, buffer_nr)
end

setup_buffer.setup_options = function(buffer_nr)
    vim.api.nvim_buf_set_option(buffer_nr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

setup_buffer.setup_highlights = function()
    vim.cmd [[
        highlight! link LspReferenceRead IncSearch
        highlight! link LspReferenceWrite IncSearch
        highlight! clear LspReferenceText
    ]]
end

setup_buffer.setup_autocmds = function()
    vim.cmd [[
        augroup LSP_document_highlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END

        augroup LSP_popup_help
            autocmd! * <buffer>
            autocmd CursorHold,CursorHoldI <buffer> lua vim.lsp.diagnostic.show_line_diagnostics()
            autocmd CursorHoldI <buffer> lua vim.lsp.buf.signature_help()
        augroup END
    ]]
end

return setup_buffer

