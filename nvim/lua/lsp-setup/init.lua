local lsp = require("lspconfig")
local setup_buffer = require("lsp-setup/buffer_setup")
local misc = require("lib/misc")
local core = require("lib/core")

-- setup keymaps and autocommands
local on_attach = function(client, buffer_nr)
    -- NOTE(vir): now using nvim-notify
    -- print("[LSP] Active")
    require("notify")(string.format('[lsp] %s\n[cwd] %s', client.name, misc.get_cwd()),
                                    'info', {title = '[lsp] Active'})

    setup_buffer.setup_general_keymaps(client, buffer_nr)
    setup_buffer.setup_independent_keymaps(client, buffer_nr)
    setup_buffer.setup_options(client, buffer_nr)
    setup_buffer.setup_autocmds(client, buffer_nr)
    setup_buffer.setup_highlights()
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
capabilities.offsetEncoding = {'utf-16'}

-- pyright setup
lsp["pyright"].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- clangd setup
lsp["clangd"].setup {
    capabilities = capabilities,
    cmd = {
      "clangd",
      "--background-index",
      "--suggest-missing-includes",
      "--clang-tidy",
      "--completion-style=bundled",
      "--header-insertion=iwyu"
    },
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- sumneko_lua setup
-- vim runtime files
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/initlua')

-- sumneko_lua location
local sumneko_lua_root = core.get_homedir() .. "/.local/lsp/lua-language-server/"
local sumneko_lua_bin = sumneko_lua_root .. "bin/" .. core.get_os() .. "/lua-language-server"
lsp["sumneko_lua"].setup {
    capabilities = capabilities,
    cmd = {sumneko_lua_bin, "-E", sumneko_lua_root .. "main.lua"},
    settings = {
        Lua = {
            runtime = {version = "LuaJIT", path = runtime_path},
            diagnostics = {globals = {"vim", "use", "packer_plugins"}},
            telemetry = {enable = false},
            workspace = {library = vim.api.nvim_get_runtime_file('', true)}
        }
    },
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- cmake setup
lsp['cmake'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- null-ls setup
local null_ls = require('null-ls')
null_ls.setup({
    sources = {
        null_ls.builtins.formatting.stylua,
        null_ls.builtins.formatting.autopep8,
        null_ls.builtins.formatting.prettier,
        -- null_ls.builtins.diagnostics.flake8,
        null_ls.builtins.completion.spell.with({filetypes={'text'}})
    },
    capabilities = capabilities,
    on_attach = function(client, buffer_nr)
        -- NOTE(vir): now using nvim-notify
        require("notify")(string.format('[lsp] %s\n[cwd] %s', client.name, misc.get_cwd()),
                          'info', {title = '[lsp] active'})

        setup_buffer.setup_independent_keymaps(client, buffer_nr)
    end,
    flags = {debounce_text_changes = 150}
})

