local utils = require('utils')
local lsp = require('lspconfig')

-- setup keymaps and autocommands
local on_attach = function(client, buffer_nr)
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

    vim.cmd [[ command! Errors :lua vim.lsp.diagnostic.set_loclist()<cr> ]]
    vim.api.nvim_buf_set_option(buffer_nr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
end

-- custom handlers
vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
        signs = true,
        virtual_text = { spacing = 4 },
        update_in_insert = true
    }
)

vim.lsp.handlers["textDocument/definition"] = function(_, _, result)
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

-- custom signs
vim.fn.sign_define("LspDiagnosticsSignError", {text = "x" })
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "!" })
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "i" })
vim.fn.sign_define("LspDiagnosticsSignHint", {text = "@" })

-- lsp setup
lsp['clangd'].setup{ on_attach = on_attach }
lsp['pyls'].setup{ on_attach = on_attach }

local sumneko_lua_root = '/home/viraat-chandra/.local/lsp/lua-language-server/'
local sumneko_lua_bin = sumneko_lua_root .. 'bin/Linux/lua-language-server'
lsp['sumneko_lua'].setup {
    cmd = { sumneko_lua_bin, '-E', sumneko_lua_root .. 'main.lua' },
    settings = {
        Lua = {
            runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
            diagnostics = { globals = {'vim'} },
            workspace = { library = {[vim.fn.expand('$VIMRUNTIME/lua')] = true, [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true} }
        }
    },
    on_attach = on_attach
}

-- completion setup
require('compe').setup {
    debug = false,
    enabled = true,
    autocomplete = true,
    min_length = 1,
    preselect = 'enable',
    max_abbr_width = 100,
    max_kind_width = 100,
    max_menu_width = 100,
    documentation = true,

    source = {
        path = true,
        buffer = true,
        calc = true,
        nvim_lsp = true,
        nvim_lua = true
    }
}

utils.map('i', '<c-space>', 'compe#complete()', { silent = true, expr = true })
utils.map('i', '<cr>', 'compe#confirm("<cr>")', { silent = true, expr = true })
utils.map('i', '<c-e>', 'compe#close("<c-e>")', { silent = true, expr = true })
utils.map('i', '<c-f>', 'compe#scroll({ "delta": +4 })', { silent = true, expr = true })
utils.map('i', '<c-d>', 'compe#scroll({ "delta": -4 })', { silent = true, expr = true })

