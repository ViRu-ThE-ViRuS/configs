local utils = require('utils')
local lsp = require('lspconfig')
local lsp_status = require('lsp-status')

local on_attach = function(client, buffer_nr)
    print('[LSP] Active')
    require('completion').on_attach(client)

    vim.api.nvim_buf_set_option(buffer_nr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
    lsp_status.on_attach(client)

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

    vim.cmd [[
    command! Errors :lua vim.lsp.diagnostic.set_loclist()<cr>
    ]]
end

local servers = { 'clangd', 'pyls' }
for _, server in ipairs(servers) do
    lsp[server].setup { on_attach = on_attach, capabilities = lsp_status.capabilities }
end

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

vim.fn.sign_define("LspDiagnosticsSignError", {text = "x" })       -- , texthl = "GruvboxRed"})
vim.fn.sign_define("LspDiagnosticsSignWarning", {text = "!" })     -- , texthl = "GruvboxYellow"})
vim.fn.sign_define("LspDiagnosticsSignInformation", {text = "i" }) -- , texthl = "GruvboxBlue"})
vim.fn.sign_define("LspDiagnosticsSignHint", {text = "@" })        -- , texthl = "GruvboxAqua"})

vim.cmd [[ autocmd BufEnter * lua require'completion'.on_attach() ]]
vim.g.completion_matching_strategy_list = {'exact', 'substring', 'fuzzy', 'all'}
vim.g.completion_confirm_key = ''
vim.g.completion_trigger_on_delete = 1
vim.g.completion_auto_change_source = 1
vim.g.completion_trigger_keyword_length = 3
vim.g.completion_menu_length = 10
vim.g.completion_abbr_length = 50

vim.g.completion_chain_complete_list = {
  default = {
    { complete_items = { 'lsp' } },
    { complete_items = { 'buffers' } },
    { mode = { '<c-p>' } },
    { mode = { '<c-n>' } }
  }
}

utils.map('i', '<tab>', '<plug>(completion_smart_tab)', { noremap = false })
utils.map('i', '<s-tab>', '<plug>(completion_smart_s_tab)', { noremap = false })
