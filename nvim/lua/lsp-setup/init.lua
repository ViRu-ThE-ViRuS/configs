-- Load lspconfig to add server configs to Neovim's runtime path
-- This makes server configurations available to vim.lsp.config()
require('lspconfig')

local setup_buffer = require("lsp-setup/buffer_setup")
local utils = require("utils")

-- vim.lsp.set_log_level("debug")

local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.offsetEncoding = { 'utf-16' } -- workaround to some weird bug

-- {{{ LspAttach autocmd - replaces on_attach
-- This is the new Neovim 0.11+ way to handle LSP buffer setup
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', { clear = true }),
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    if not client then return end

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
  end,
})
-- }}}

-- {{{ Set global defaults for all LSP servers
vim.lsp.config('*', {
  capabilities = capabilities,
})
-- }}}

-- {{{ pyright setup
vim.lsp.config('pyright', {
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
})
-- }}}

-- {{{ clangd setup
vim.lsp.config('clangd', {
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
})
-- }}}

-- {{{ lua_ls setup
-- vim runtime files
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, 'lua/?.lua')
table.insert(runtime_path, 'lua/?/init.lua')

vim.lsp.config('lua_ls', {
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

vim.lsp.config('efm', {
  filetypes = vim.tbl_keys(languages),
  settings = {
    rootMarkers = { '.git/' },
    languages = languages
  },
  init_options = {
    documentFormatting = true,
    documentRangeFormatting = true,
  },
})
-- }}}

-- {{{ null-ls setup
local null_ls = require('null-ls')
null_ls.setup({
  sources = {
    null_ls.builtins.completion.spell.with({ filetypes = { 'text', 'markdown' } }),
    null_ls.builtins.formatting.shfmt.with({ filetypes = { 'sh', 'bash' } })
  },
  capabilities = capabilities,
})
-- }}}

-- {{{ Enable all LSP servers
vim.lsp.enable({
  'pyright',
  'clangd',
  'lua_ls',
  'efm',
})
-- }}}
