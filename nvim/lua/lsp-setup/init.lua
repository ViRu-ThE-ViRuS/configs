local lsp = require("lspconfig")
local setup_buffer = require("lsp-setup/buffer_setup")
local utils = require("utils")

-- vim.lsp.set_log_level("debug")

-- setup keymaps and autocommands
local function on_attach(client, bufnr)
  -- utils.notify(
  --     string.format("[SERVER] %s\n[CWD] %s", client.name, vim.loop.cwd()),
  --     "info",
  --     { title = "[LSP] active" },
  --     true
  -- )

  -- NOTE(vir): this is what causes a delayed change in highlighting
  -- client.server_capabilities.semanticTokensProvider = nil

  -- NOTE(vir): lsp_signature setup
  require('lsp_signature').on_attach({ doc_lines = 5, hint_prefix = "<>", handler_opts = { border = 'rounded' } }, bufnr)

  setup_buffer.setup_lsp_keymaps(client, bufnr)
  setup_buffer.setup_diagnostics_keymaps(client, bufnr)
  setup_buffer.setup_formatting_keymaps(client, bufnr)
  setup_buffer.setup_commands(client, bufnr)

  setup_buffer.setup_autocmds(client, bufnr)
  setup_buffer.setup_options(client, bufnr)
end

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.offsetEncoding = { 'utf-16' } -- workaround to some weird bug

-- {{{ pyright setup
lsp["pyright"].setup {
  capabilities = capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = 'off',
        diagnosticMode = 'workspace',
        autoSearchPaths = true,
        autoImportCompletions = true,
        useLibraryCodeForTypes = true,
      }
    }
  },
  on_attach = on_attach,
  flags = { debounce_text_changes = 150 }
}
-- }}}

-- {{{ clangd setup
lsp["clangd"].setup {
  capabilities = capabilities,
  cmd = {
    "clangd",
    "--background-index",
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
  flags = { debounce_text_changes = 150 }
}
-- }}}

-- {{{ lua_ls setup
-- vim runtime files
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

lsp["lua_ls"].setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT", path = runtime_path },
      diagnostics = { globals = { "vim", "use", "packer_plugins", "require", "session" } },
      telemetry = { enable = false },
      workspace = {
        library = {
          vim.api.nvim_get_runtime_file('', true),
          -- vim.fn.stdpath('config'),
          -- vim.fn.stdpath('config') .. '/lua',
        },
        maxPreload = 1000,
        preloadFileSize = 150
      }
    }
  },
  on_attach = on_attach,
  flags = { debounce_text_changes = 150 }
}
-- }}}

-- {{{ js/ts setup
lsp['tsserver'].setup {
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- disable formatting
    client.server_capabilities.documentFormattingProvider      = false
    client.server_capabilities.documentRangeFormattingProvider = false

    on_attach(client, bufnr)
  end,
  flags = { debounce_text_changes = 150 }
}
-- }}}

-- {{{ null-ls setup
-- NOTE(vir): plugin null-ls
local null_ls = require('null-ls')
null_ls.setup({
  sources = {
    null_ls.builtins.completion.spell.with({ filetypes = { 'text', 'markdown' } }),
    -- null_ls.builtins.diagnostics.cppcheck,
    null_ls.builtins.formatting.autopep8,
    null_ls.builtins.formatting.prettier.with({ filetypes = { 'markdown', 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } }),
    null_ls.builtins.hover.dictionary.with({ filetypes = { 'text', 'markdown' } }),
  },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    -- utils.notify(
    --     string.format("[SERVER] %s\n[CWD] %s", client.name, vim.loop.cwd()),
    --     "info",
    --     { title = "[LSP] active" },
    --     true
    -- )

    utils.map('n', 'K', vim.lsp.buf.hover, { silent = true, buffer = bufnr })
    setup_buffer.setup_diagnostics_keymaps(client, bufnr)
    setup_buffer.setup_formatting_keymaps(client, bufnr)
  end,
  flags = { debounce_text_changes = 150 }
})
-- }}}
