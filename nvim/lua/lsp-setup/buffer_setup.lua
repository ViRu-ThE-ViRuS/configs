local utils = require('utils')
ToggleDiagnosticsList = require('lsp-setup/utils').ToggleDiagnosticsList
CMDLineDiagnostics = require('lsp-setup/utils').CMDLineDiagnostics
RefreshTagState = require('lsp-setup/utils').RefreshTagState
SetupLspIconHighlights = require('lsp-setup/utils').SetupLspIconHighlights

M = {}

-- setup general keymaps
M.setup_general_keymaps = function(buffer_nr)
	utils.map('n','<leader>d', '<cmd>lua vim.lsp.buf.definition()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>u', '<cmd>lua vim.lsp.buf.references()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>r','<cmd>lua vim.lsp.buf.rename()<cr>', { silent = true }, buffer_nr)
	utils.map('n','K', '<cmd>lua vim.lsp.buf.hover()<cr>', { silent = true }, buffer_nr)
    utils.map('n','<a-cr>', '<cmd>lua vim.lsp.buf.code_action()<cr>', { silent = true }, buffer_nr)
    utils.map('n','<c-f>', '<cmd>lua vim.lsp.buf.formatting()<cr>', { silent = true }, buffer_nr)
    utils.map('v','<c-f>', '<cmd>lua vim.lsp.buf.range_formatting()<cr>', { silent = true }, buffer_nr)

    utils.map('n','[e', '<cmd>lua vim.lsp.diagnostic.goto_prev({ popup_opts = { border = "single", focusable = false } })<cr>', { silent = true }, buffer_nr)
    utils.map('n',']e', '<cmd>lua vim.lsp.diagnostic.goto_next({ popup_opts = { border = "single", focusable = false } })<cr>', { silent = true }, buffer_nr)
    utils.map('n','[q', '<cmd>cprevious<cr>', { silent = true }, buffer_nr)
    utils.map('n',']q', '<cmd>cnext<cr>', { silent = true }, buffer_nr)

    utils.map('n', '<leader>e', '<cmd>lua ToggleDiagnosticsList()<cr>', { silent = true }, buffer_nr)
end

-- setup buffer options
M.setup_options = function(buffer_nr)
    vim.api.nvim_buf_set_option(buffer_nr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- setup highlights
M.setup_highlights = function()
    vim.cmd [[
        highlight! link LspReferenceRead IncSearch
        highlight! link LspReferenceWrite IncSearch
        highlight! clear LspReferenceText
    ]]

    SetupLspIconHighlights()
end

-- setup buffer autocommands
M.setup_autocmds = function()
    vim.cmd [[
        augroup LspDocumentHighlight
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
            autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
        augroup END

        augroup LspPopupHelp
            autocmd! * <buffer>
            autocmd CursorHold <buffer> lua vim.lsp.diagnostic.show_line_diagnostics({ border='single', focusable=false })
            autocmd CursorHoldI <buffer> lua vim.lsp.buf.signature_help()
        augroup END

        augroup LspUpdateStates
            autocmd! * <buffer>
            autocmd CursorMoved,CursorMovedI,BufEnter <buffer> lua RefreshTagState()
            " autocmd CursorHoldI <buffer> lua CMDLineDiagnostics()
            " autocmd CursorMovedI <buffer> echo ''
        augroup END
    ]]
end

return M

