local lsp = require('lspconfig')
local utils = require('utils')

-- setup keymaps and autocommands
OnAttach = function(_, buffer_nr)
    print('[LSP] Active')

	utils.map('n','<leader>d', '<cmd>lua vim.lsp.buf.definition()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>u', '<cmd>lua vim.lsp.buf.references()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>r','<cmd>lua vim.lsp.buf.rename()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<a-cr>', '<cmd>lua vim.lsp.buf.code_action()<cr>', { silent = true }, buffer_nr)
    utils.map('n','<c-f>', '<cmd>lua vim.lsp.buf.formatting()<cr>', { silent = true }, buffer_nr)
    utils.map('v','<c-f>', '<cmd>lua vim.lsp.buf.range_formatting()<cr>', { silent = true }, buffer_nr)
    utils.map('n','[e', '<cmd>lua vim.lsp.diagnostic.goto_prev()<cr>', { silent = true }, buffer_nr)
    utils.map('n',']e', '<cmd>lua vim.lsp.diagnostic.goto_next()<cr>', { silent = true }, buffer_nr)

    utils.map('n', '<leader>l', '<cmd>lua vim.lsp.diagnostic.set_loclist()<cr>')
    vim.cmd [[
        highlight! link LspReferenceRead IncSearch
        highlight! link LspReferenceWrite IncSearch
        highlight! clear LspReferenceText

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

    vim.api.nvim_buf_set_option(buffer_nr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- pyls setup
lsp['pyls'].setup{ on_attach = OnAttach, cmd = {"pylsp"} }

-- clangd setup
lsp['clangd'].setup{ on_attach = OnAttach }

-- sumneko_lua setup
local sumneko_lua_root = '/home/viraat-chandra/.local/lsp/lua-language-server/'
local sumneko_lua_bin = sumneko_lua_root .. 'bin/Linux/lua-language-server'
lsp['sumneko_lua'].setup {
    cmd = { sumneko_lua_bin, '-E', sumneko_lua_root .. 'main.lua' },
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
            diagnostics = { globals = { 'vim', 'use' } },
            workspace = { library = { [vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true } }
        }
    },
    on_attach = OnAttach
}

