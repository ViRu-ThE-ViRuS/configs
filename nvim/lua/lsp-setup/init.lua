local lsp = require('lspconfig')
local setup_buffer = require('lsp-setup/buffer_setup')

-- setup keymaps and autocommands
OnAttach = function(_, buffer_nr)
    print('[LSP] Active')

    setup_buffer.setup_general_keymaps(buffer_nr)
    setup_buffer.setup_options(buffer_nr)
    setup_buffer.setup_highlights()
    setup_buffer.setup_autocmds()
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

