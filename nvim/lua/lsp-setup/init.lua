local lsp = require("lspconfig")
local setup_buffer = require("lsp-setup/buffer_setup")
local oslib = require("lib/oslib")

-- setup keymaps and autocommands
OnAttach = function(client, buffer_nr)
    print("[LSP] Active")
    -- print('[LSP] Active : ' .. oslib.get_cwd())

    setup_buffer.setup_general_keymaps(client, buffer_nr)
    setup_buffer.setup_independent_keymaps(client, buffer_nr)
    setup_buffer.setup_options(buffer_nr)
    setup_buffer.setup_highlights()
    setup_buffer.setup_autocmds()
end

-- pyright setup
lsp["pyright"].setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    on_attach = OnAttach,
    flags = {debounce_text_changes = 150}
}

-- clangd setup
lsp["clangd"].setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    on_attach = OnAttach,
    flags = {debounce_text_changes = 150}
}

-- sumneko_lua setup
local sumneko_lua_root = oslib.get_homedir() .. "/.local/lsp/lua-language-server/"
local sumneko_lua_bin = sumneko_lua_root .. "bin/" .. oslib.get_os() .. "/lua-language-server"
lsp["sumneko_lua"].setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    cmd = {sumneko_lua_bin, "-E", sumneko_lua_root .. "main.lua"},
    settings = {
        Lua = {
            runtime = {version = "LuaJIT", path = vim.split(package.path, ";")},
            diagnostics = {globals = {"vim", "use"}},
            workspace = {
                library = {[vim.fn.expand("$VIMRUNTIME/lua")] = true, [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true}
            }
        }
    },
    on_attach = OnAttach,
    flags = {debounce_text_changes = 150}
}

-- efm setup
local efm_prettier = {formatCommand = "prettier --stdin-filepath ${INPUT}", formatStdin = true}
lsp["efm"].setup {
    capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities()),
    init_options = {documentFormatting = true},
    filetypes = {
        "css",
        "html",
        "javascript",
        "javascriptreact",
        "json",
        "lua",
        "markdown",
        "python"
    },
    settings = {
        rootMarkers = {".git/"},
        languages = {
            css = {efm_prettier},
            html = {efm_prettier},
            javascript = {efm_prettier},
            javascriptreact = {efm_prettier},
            json = {efm_prettier},
            lua = {{formatCommand = "luafmt --stdin", formatStdin = true}},
            markdown = {efm_prettier},
            python = {{formatCommand = "autopep8 -", formatStdin = true}}
        }
    },
    on_attach = function(client, buffer_nr)
        setup_buffer.setup_independent_keymaps(client, buffer_nr)
    end
}
