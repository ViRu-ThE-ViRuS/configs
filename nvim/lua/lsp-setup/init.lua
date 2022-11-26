local lsp = require("lspconfig")
local setup_buffer = require("lsp-setup/buffer_setup")
local misc = require("lib/misc")
local utils = require("utils")

-- vim.lsp.set_log_level("debug")

-- setup keymaps and autocommands
local on_attach = function(client, bufnr)
    utils.notify(string.format("[lsp] %s\n[cwd] %s", client.name, misc.get_cwd()), "info", { title = "[lsp] Active" }, true)

    -- NOTE(vir): lsp_signature setup
    require('lsp_signature').on_attach({ doc_lines = 3, hint_prefix = "<>", handler_opts = { border = 'rounded' } }, bufnr)

    setup_buffer.setup_lsp_keymaps(client, bufnr)
    setup_buffer.setup_diagnostics_keymaps(client, bufnr)
    setup_buffer.setup_formatting_keymaps(client, bufnr)
    setup_buffer.setup_independent_keymaps(client, bufnr)

    setup_buffer.setup_autocmds(client, bufnr)
    setup_buffer.setup_options()
    setup_buffer.setup_highlights()
end

-- workaround to some weird bug
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.offsetEncoding = {'utf-16'}

-- pyright setup
lsp["pyright"].setup {
    capabilities = capabilities,
    settings = {
        pyright = {
            typeCheckingMode = 'basic',
            diagnosticMode = 'workspace',
            autoSearchPaths = true,
            autoImportCompletions = true,
            useLibraryCodeForTypes = true,
        }
    },
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- clangd setup
lsp["clangd"].setup {
    capabilities = capabilities,
    cmd = {
        "clangd",
        "--index",
        "--background-index",
        "--suggest-missing-includes",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders"
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true
    },
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- sumneko_lua setup
-- vim runtime files
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

-- sumneko_lua location
lsp["sumneko_lua"].setup {
    capabilities = capabilities,
    settings = {
        Lua = {
            runtime = {version = "LuaJIT", path = runtime_path},
            diagnostics = {globals = {"vim", "use", "packer_plugins"}},
            telemetry = {enable = false},
            workspace = {
                library = {
                    vim.api.nvim_get_runtime_file('', true),

                    -- vim.api.nvim_get_runtime_file('lua', true),
                    -- vim.api.nvim_get_runtime_file("lua/vim/lsp", true),
                    -- vim.fn.stdpath('config') ,
                },
                maxPreload = 1000,
                preloadFileSize = 150
            }
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

-- js/ts setup
lsp['tsserver'].setup {
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        -- disable formatting
        client.server_capabilities.documentFormattingProvider  = false
        client.server_capabilities.documentRangeFormattingProvider = false

        on_attach(client, bufnr)
    end,
    flags = {debounce_text_changes = 150},
    commands = {
        OrganizeImports = { function()
            local params = {
                command = "_typescript.organizeImports",
                arguments = { vim.api.nvim_buf_get_name(0) },
                title = ""
            }
            vim.lsp.buf.execute_command(params)
        end, description = "Organize Imports" }
    }
}

-- null-ls setup
-- NOTE(vir): extension null-ls
local null_ls = require('null-ls')
null_ls.setup({
    sources = {
        null_ls.builtins.completion.spell.with({filetypes={'text', 'markdown'}}),
        null_ls.builtins.diagnostics.cppcheck,
        null_ls.builtins.formatting.autopep8,
        null_ls.builtins.formatting.prettier.with({filetypes={'markdown', 'javascript', 'javascriptreact', 'javascript.jsx', 'typescript', 'typescriptreact', 'typescript.tsx'}}),
        null_ls.builtins.hover.dictionary.with({filetypes={'text', 'markdown'}}),
    },
    capabilities = capabilities,
    on_attach = function(client, bufnr)
        utils.notify(
            string.format("[lsp] %s\n[cwd] %s", client.name, misc.get_cwd()),
            "info", { title = "[lsp] Active" }, true
        )

        setup_buffer.setup_formatting_keymaps(client, bufnr)
        setup_buffer.setup_diagnostics_keymaps(client, bufnr)
        utils.map('n', 'K', vim.lsp.buf.hover, {silent = true}, bufnr)
    end,
    flags = {debounce_text_changes = 150}
})

