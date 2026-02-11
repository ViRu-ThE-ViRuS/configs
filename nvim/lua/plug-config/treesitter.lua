-- get all functions present in current buffer in qf list entry format, using treesitter
local function buffer_functions()
  local ft = vim.api.nvim_get_option_value('ft', { scope = 'local' })
  local bufnr = vim.api.nvim_get_current_buf()

  local valid, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
  if not valid then return end

  local tree = parser:parse()[1]
  local functions = vim.treesitter.query.parse(
    ft,

    -- NOTE(vir): add support more more languages as needed
    table.concat({
      '((function_definition) @definitions)',
      ((ft == 'lua' and '((function_declaration) @lua_declaration)') or ""),
      ((ft == 'cpp' and '((lambda_expression) @cpp_lambda)') or ""),
      ((ft == 'python' and '((lambda) @py_lambda)') or "")
    }, '\n')
  )

  local entries = {}
  for _, node, _ in functions:iter_captures(tree:root(), bufnr) do
    local l1, c1, _, _ = node:start()
    table.insert(entries, {
      bufnr = bufnr,
      lnum = l1 + 1,
      col = c1 + 1,
      text = vim.split(vim.treesitter.get_node_text(node, bufnr), '\n')[1]
    })
  end

  return entries
end

-- move cursor to lsp-parent
local function up_lsp_stack()
  local context = require('lsp-setup/lsp_utils').get_context()
  if not context then return end

  local current_line = vim.api.nvim_win_get_cursor(0)
  local head = nil

  for index = #context, 1, -1 do
    head = context[index]
    if head.range.start.line < current_line[1] then break end
  end

  if head then
    -- add current location to jump list, then jump
    vim.cmd [[ normal! m` ]]
    vim.api.nvim_win_set_cursor(0, { head.range.start.line, head.range['end'].line })
  end
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPre',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'MeanderingProgrammer/treesitter-modules.nvim',
      'andymass/vim-matchup',
      'machakann/vim-sandwich'
    },
    config = function()
      local utils = require("utils")

      vim.g.skip_ts_context_commentstring_module = true
      require('nvim-treesitter').setup({
        ensure_installed = {
          'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish',
          'cmake', 'make', 'cuda', 'rust', 'vim', 'vimdoc', 'markdown',
          'javascript', 'typescript', 'tsx', 'query', 'glsl', 'jsonc',
          'dockerfile', 'markdown_inline', 'diff'
        },
        matchup = { enable = true, disable_virtual_text = true },
      })

      require('treesitter-modules').setup({
        indent = { enable = true, disable = { 'c', 'cpp', 'lua' } },
        highlight = { enable = true, additional_vim_regex_highlighting = { 'markdown' }, disable = { 'gitcommit' } },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<m-=>',
            node_incremental = '<m-=>',
            node_decremental = '<m-->',
            scope_incremental = '+'
          }
        },
      })

      -- textobjects setup
      require('nvim-treesitter-textobjects').setup({
        select = { lookahead = true },
        move = { set_jumps = true },
      })

      -- textobjects: select
      local ts_select = require('nvim-treesitter-textobjects.select')
      vim.keymap.set({ 'x', 'o' }, 'af', function() ts_select.select_textobject('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'if', function() ts_select.select_textobject('@function.inner', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'an', function() ts_select.select_textobject('@block.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'in', function() ts_select.select_textobject('@block.inner', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'aP', function() ts_select.select_textobject('@parameter.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'iP', function() ts_select.select_textobject('@parameter.inner', 'textobjects') end)

      -- textobjects: swap
      local ts_swap = require('nvim-treesitter-textobjects.swap')
      vim.keymap.set('n', ']p', function() ts_swap.swap_next('@parameter.inner', 'textobjects') end)
      vim.keymap.set('n', '[p', function() ts_swap.swap_previous('@parameter.inner', 'textobjects') end)

      -- textobjects: move + center
      local ts_move = require('nvim-treesitter-textobjects.move')
      utils.map({ 'n', 'o', 'x' }, ']F', function() ts_move.goto_next_start('@class.outer', 'textobjects') vim.cmd('normal! zz') end)
      utils.map({ 'n', 'o', 'x' }, '[F', function() ts_move.goto_previous_start('@class.outer', 'textobjects') vim.cmd('normal! zz') end)
      utils.map({ 'n', 'o', 'x' }, ']f', function() ts_move.goto_next_start('@function.outer', 'textobjects') vim.cmd('normal! zz') end)
      utils.map({ 'n', 'o', 'x' }, '[f', function() ts_move.goto_previous_start('@function.outer', 'textobjects') vim.cmd('normal! zz') end)
      utils.map({ 'n', 'o', 'x' }, '[[', function() ts_move.goto_previous_start('@block.outer', 'textobjects') vim.cmd('normal! zz') end)
      utils.map({ 'n', 'o', 'x' }, ']]', function() ts_move.goto_next_start('@block.outer', 'textobjects') vim.cmd('normal! zz') end)

      -- lsp_interop: peek definition (replaces removed textobjects feature)
      vim.keymap.set('n', 'gK', function()
        local client = vim.lsp.get_clients({ bufnr = 0 })[1]
        if not client then return end
        local params = vim.lsp.util.make_position_params(0, client.offset_encoding)
        vim.lsp.buf_request(0, 'textDocument/definition', params, function(err, result)
          if err or not result or vim.tbl_isempty(result) then return end
          local def = vim.islist(result) and result[1] or result
          vim.lsp.util.preview_location(def, { border = 'rounded' })
        end)
      end)

      require('ts_context_commentstring').setup {}

      -- populate all functions and lambdas into qflist
      utils.map('n', '<leader>uf', function()
        utils.qf_populate(buffer_functions(), { title = 'Functions & Lambdas' })
      end)

      -- jump to lsp-parent
      utils.map({ 'n', 'o', 'x' }, '[S', up_lsp_stack)
    end
  },

  { "wurli/contextindent.nvim",   event = "InsertEnter",     dependencies = { "nvim-treesitter/nvim-treesitter" } },
}
