local utils = require('utils')
local lsp_utils = require('lsp-setup/utils')

-- setup lsp keymaps
local function setup_lsp_keymaps(_, buffer_nr)
    -- NOTE(vir): now using fzf-lua
    utils.map("n", "<leader>uS", vim.lsp.buf.references, {silent = true}, buffer_nr)
    utils.map('n', '<leader>r', vim.lsp.buf.rename, {silent = true}, buffer_nr)
    utils.map('n', 'K', vim.lsp.buf.hover, {silent = true}, buffer_nr)
end

-- setup diagnostic keymaps
local function setup_diagnostics_keymaps(_, buffer_nr)
    utils.map('n', '[e', function() vim.diagnostic.goto_prev({ float = true }) end, {silent = true}, buffer_nr)
    utils.map('n', ']e', function() vim.diagnostic.goto_next({ float = true }) end, {silent = true}, buffer_nr)
    utils.map('n', '<leader>e', function() lsp_utils.toggle_diagnostics_list(false) end, {silent = true}, buffer_nr)
    utils.map('n', '<leader>E', function() lsp_utils.toggle_diagnostics_list(true) end, {silent=true}, buffer_nr)
end

-- setup auto format
local function setup_formatting_keymaps(client, buffer_nr)
    if client.server_capabilities.documentFormattingProvider then
        utils.map('n', '<c-f>', function() vim.lsp.buf.format({async=true}) end, {silent = true}, buffer_nr)
    end

    if client.server_capabilities.documentRangeFormattingProvider then
        utils.map('v', '<c-f>', '<esc><cmd>lua vim.lsp.buf.range_formatting()<cr>', {silent = true}, buffer_nr)
    end
end

-- setup independent keymaps
local function setup_independent_keymaps(client, buffer_nr)
    if client.name == 'clangd' then
        utils.map('n', '<f9>', '<cmd>ClangdSwitchSourceHeader<cr>', {}, buffer_nr)
    elseif client.name == 'pyright' then
        utils.map('n', '<f9>', '<cmd>PyrightOrganizeImports<cr>', {}, buffer_nr)
    end
end

-- setup buffer options
local function setup_options()
    vim.opt_local.omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.opt_local.formatoptions = "cqnjlr"
end

-- setup buffer autocommands
local function setup_autocmds(client, buffer_nr)
    -- NOTE(vir): these are setup per buffer, so no need to clear autogroups
    vim.api.nvim_create_augroup('LspPopups', { clear = false })
    vim.api.nvim_create_autocmd('CursorHold', { group = 'LspPopups', callback = vim.diagnostic.open_float, buffer = buffer_nr })

    if client.server_capabilities.documentHighlightProvider then
        vim.api.nvim_create_augroup('LspHighlights', { clear = false })
        vim.api.nvim_create_autocmd('CursorHold', { group = 'LspHighlights', callback = vim.lsp.buf.document_highlight, buffer = buffer_nr })
        vim.api.nvim_create_autocmd('CursorMoved', { group = 'LspHighlights', callback = vim.lsp.buf.clear_references, buffer = buffer_nr })
    end

    if client.server_capabilities.documentSymbolProvider then
        vim.api.nvim_create_augroup('LspStates', { clear = false })
        vim.api.nvim_create_autocmd('CursorMoved,InsertLeave,BufEnter', { group = 'LspStates', callback = lsp_utils.refresh_tag_state, buffer = buffer_nr })
        vim.api.nvim_create_autocmd('BufLeave', { group = 'LspStates', callback = lsp_utils.reset_tag_state, buffer = buffer_nr })
    end
end

-- setup buffer highlights
local function setup_highlights()
end

return {
    setup_lsp_keymaps = setup_lsp_keymaps,
    setup_diagnostics_keymaps = setup_diagnostics_keymaps,
    setup_formatting_keymaps = setup_formatting_keymaps,
    setup_independent_keymaps = setup_independent_keymaps,

    setup_options = setup_options,
    setup_autocmds = setup_autocmds,
    setup_highlights = setup_highlights
}

