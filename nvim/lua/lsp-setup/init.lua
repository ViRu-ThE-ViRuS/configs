local lsp = require('lspconfig')
local utils = require('utils')

-- setup keymaps and autocommands
OnAttach = function(client, buffer_nr)
    print('[LSP] Active')

	utils.map('n','<leader>d', '<cmd>lua vim.lsp.buf.definition()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>u', '<cmd>lua vim.lsp.buf.references()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>r','<cmd>lua vim.lsp.buf.rename()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<leader>h', '<cmd>lua vim.lsp.buf.hover()<cr>', { silent = true }, buffer_nr)
	utils.map('n','<a-cr>', '<cmd>lua vim.lsp.buf.code_action()<cr>', { silent = true }, buffer_nr)

    if client.resolved_capabilities.document_formatting then
        utils.map('n','<c-f>', '<cmd>lua vim.lsp.buf.formatting()<cr>', { silent = true }, buffer_nr)
    end

    if client.resolved_capabilities.document_range_formatting then
        utils.map('v','<c-f>', '<cmd>lua vim.lsp.buf.range_formatting()<cr>', { silent = true }, buffer_nr)
    end

    vim.api.nvim_buf_set_option(buffer_nr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    vim.cmd [[ command! Errors :lua vim.lsp.diagnostic.set_loclist()<cr> ]]
    utils.map('n', '<leader>l', '<cmd>Errors<cr>')
end

-- pyls setup
lsp['pyls'].setup{ on_attach = OnAttach }

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
            diagnostics = { globals = {'vim', 'use' } },
            workspace = { library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true} }
        }
    },
    on_attach = OnAttach
}

