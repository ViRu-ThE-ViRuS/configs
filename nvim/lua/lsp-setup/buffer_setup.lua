local core = require('lib/core')
local lsp_utils = require('lsp-setup/lsp_utils')
local utils = require('utils')

-- setup lsp keymaps
local function setup_lsp_keymaps(_, bufnr)
  local map_opts = { silent = true, buffer = bufnr }

  -- NOTE(vir): using fzf-lua for lsp functionality
  require('plug-config/fzf').module_exports.set_lsp_keymaps(_, bufnr)

  utils.map('n', 'K', vim.lsp.buf.hover, map_opts)
  utils.map('n', '<leader>R', vim.lsp.buf.rename, map_opts)
  utils.map("n", "<leader>uS", vim.lsp.buf.references, map_opts)

  -- custom refactorings
  utils.map('n', 'gL', lsp_utils.debug_print, map_opts)
  utils.map('x', 'gL', '<esc><cmd>lua require("lsp-setup/lsp_utils").debug_print(true)<cr>', map_opts)
end

-- setup diagnostic keymaps
local function setup_diagnostics_keymaps(_, bufnr)
  local map_opts = { silent = true, buffer = bufnr }
  utils.map('n', '[e', core.partial(vim.diagnostic.goto_prev, { float = true }), map_opts)
  utils.map('n', ']e', core.partial(vim.diagnostic.goto_next, { float = true }), map_opts)
  utils.map('n', '<leader>e', core.partial(lsp_utils.toggle_diagnostics_list, false), map_opts)
  utils.map('n', '<leader>E', core.partial(lsp_utils.toggle_diagnostics_list, true), map_opts)
end

-- setup formatting keymaps
local function setup_formatting_keymaps(client, bufnr)
  local map_opts = { silent = true, buffer = bufnr }

  if client.server_capabilities.documentFormattingProvider then
    utils.map('n', '<c-f>', core.partial(vim.lsp.buf.format, { async = true }), map_opts)
  end

  if client.server_capabilities.documentRangeFormattingProvider then
    utils.map('v', '<c-f>', core.partial(vim.lsp.buf.format, { async = true }), map_opts)
  end
end

-- setup lsp related commands
local function setup_commands(client, _)
  if client.name == 'clangd' then
    utils.add_command(
      '[LSP] clangd: Switch Source Header',
      'ClangdSwitchSourceHeader',
      { add_custom = true }
    )
  end

  if client.name == 'pyright' then
    utils.add_command(
      '[LSP] pyright: Organize Imports',
      'PyrightOrganizeImports',
      { add_custom = true }
    )
  end

  -- use as commands not keymaps
  utils.add_command('[LSP] Incoming Calls', vim.lsp.buf.incoming_calls, { add_custom = true })
  utils.add_command('[LSP] Outgoing Calls', vim.lsp.buf.outgoing_calls, { add_custom = true })
  utils.add_command('[LSP] Code Actions', require('fzf-lua').lsp_code_actions, { add_custom = true })
end

-- setup buffer options
local function setup_options(_, bufnr)
  vim.opt_local.omnifunc = 'v:lua.vim.lsp.omnifunc'
  vim.opt_local.tagfunc = 'v:lua.vim.lsp.tagfunc'
  vim.opt_local.formatoptions = "cqnjlr"
  vim.opt_local.formatexpr = 'v:lua.vim.lsp.formatexpr()'

  -- set context in winbar
  if session.config.context_winbar then
    vim.opt_local.winbar = "%!luaeval(\"require('lsp-setup/lsp_utils').get_context_winbar(" .. bufnr .. ")\")"
  end

  -- enable inlay hints if configured
  if session.config.inlay_hints then
    vim.lsp.inlay_hint.enable(true, nil)
  end
end

-- setup buffer autocommands
local function setup_autocmds(client, bufnr)
  -- dont clear the group, just clear any group members for current buffer
  vim.api.nvim_create_augroup('LspPopups', { clear = false })
  vim.api.nvim_clear_autocmds({ group = 'LspPopups', buffer = bufnr })
  vim.api.nvim_create_autocmd('CursorHold', { group = 'LspPopups', callback = vim.diagnostic.open_float, buffer = bufnr })

  if client.server_capabilities.documentHighlightProvider then
    -- dont clear the group, just clear any group members for current buffer
    vim.api.nvim_create_augroup('LspHighlights', { clear = false })
    vim.api.nvim_clear_autocmds({ group = 'LspHighlights', buffer = bufnr })

    vim.api.nvim_create_autocmd('CursorHold', { group = 'LspHighlights', callback = vim.lsp.buf.document_highlight, buffer = bufnr })
    vim.api.nvim_create_autocmd('CursorMoved', { group = 'LspHighlights', callback = vim.lsp.buf.clear_references, buffer = bufnr })
  end

  if client.server_capabilities.documentSymbolProvider then
    -- dont clear the group, just clear any group members for current buffer
    vim.api.nvim_create_augroup('LspStates', { clear = false })
    vim.api.nvim_clear_autocmds({ buffer = bufnr, group = 'LspStates' })

    -- start tracking context in this buffer using the tag_states api
    vim.api.nvim_create_autocmd(
      { 'InsertLeave', 'BufEnter', 'CursorHold' },
      { group = 'LspStates', callback = lsp_utils.update_tags, buffer = bufnr }
    )
    vim.api.nvim_create_autocmd(
      { 'CursorHold', 'CursorMoved' },
      { group = 'LspStates', callback = lsp_utils.update_context, buffer = bufnr }
    )
    vim.api.nvim_create_autocmd(
      'BufDelete',
      { group = 'LspStates', callback = core.partial(lsp_utils.clear_buffer_tags, bufnr), buffer = bufnr }
    )

    -- first-call
    lsp_utils.update_tags()
  end
end

return {
  setup_lsp_keymaps         = setup_lsp_keymaps,
  setup_diagnostics_keymaps = setup_diagnostics_keymaps,
  setup_formatting_keymaps  = setup_formatting_keymaps,
  setup_commands            = setup_commands,
  setup_options             = setup_options,
  setup_autocmds            = setup_autocmds,
}
