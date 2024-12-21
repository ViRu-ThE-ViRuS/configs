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
  require('lsp_signature').on_attach(
    { doc_lines = 5, hint_prefix = "<>", handler_opts = { border = 'rounded' } },
    bufnr
  )

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
    clangdFileStatus = true,
    semanticHighlighting = true
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
      hint = { enable = true },
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

-- {{{ null-ls setup
local null_ls = require('null-ls')
null_ls.setup({
  sources = {
    null_ls.builtins.completion.spell.with({ filetypes = { 'text', 'markdown' } }),
  },
  capabilities = capabilities,
  on_attach = function(client, bufnr)
    if client.server_capabilities.hoverProvider then
      utils.map('n', 'K', vim.lsp.buf.hover, { silent = true, buffer = bufnr })
    end

    setup_buffer.setup_diagnostics_keymaps(client, bufnr)
    setup_buffer.setup_formatting_keymaps(client, bufnr)
  end,
})
-- }}}

-- {{{ efm-ls setup
local clike = {
  -- require('efmls-configs.linters.cpplint'),
}
local languages = {
  python = { require('efmls-configs.formatters.autopep8'), },
  markdown = { require('efmls-configs.formatters.prettier'), },

  c = vim.tbl_deep_extend('force', clike, {}),
  cpp = vim.tbl_deep_extend('force', clike, {}),
  cuda = vim.tbl_deep_extend('force', clike, {}),
}

lsp['efm'].setup({
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { '.git/' },
    languages = languages
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },

  capabilities = capabilities,
  on_attach = function(client, bufnr)
    if client.server_capabilities.hoverProvider then
      utils.map('n', 'K', vim.lsp.buf.hover, { silent = true, buffer = bufnr })
    end

    setup_buffer.setup_diagnostics_keymaps(client, bufnr)
    setup_buffer.setup_formatting_keymaps(client, bufnr)
  end,
  flags = { debounce_text_changes = 150 }
})
-- }}}
