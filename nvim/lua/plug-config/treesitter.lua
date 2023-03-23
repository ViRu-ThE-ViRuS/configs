-- get all functions present in current buffer in qf list entry format, using treesitter
local function buffer_functions()
  local ft = vim.api.nvim_get_option_value('ft', { scope = 'local' })
  local bufnr = vim.api.nvim_get_current_buf()

  local valid, parser = pcall(vim.treesitter.get_parser, bufnr, ft)
  if not valid then return end

  local tree = parser:parse()[1]
  local functions = vim.treesitter.query.parse_query(
    ft,

    -- TODO(vir): can add more language specific captures when needed
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
      text = vim.split(vim.treesitter.query.get_node_text(node, bufnr), '\n')[1]
    })
  end

  return entries
end

return {
  {
    'nvim-treesitter/nvim-treesitter',
    event = 'BufReadPre',
    build = ':TSUpdate',
    dependencies = {
      'nvim-treesitter/nvim-treesitter-textobjects',
      'RRethy/nvim-treesitter-textsubjects',
      'JoosepAlviste/nvim-ts-context-commentstring',
      'yioneko/nvim-yati',
      'andymass/vim-matchup',
      'machakann/vim-sandwich'
    },
    config = function()
      local utils = require("utils")

      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          'lua', 'python', 'c', 'cpp', 'java', 'go', 'bash', 'fish',
          'cmake', 'make', 'cuda', 'rust', 'vim', 'markdown',
          'javascript', 'typescript', 'tsx', 'query'
        },
        indent = { enable = true, disable = { 'python', 'c', 'cpp', 'lua' } },
        yati = { enable = true, disable = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' } },
        highlight = { enable = true, additional_vim_regex_highlighting = { 'markdown' } },
        matchup = { enable = true, disable_virtual_text = true },
        context_commentstring = { enable = true, enable_autocmd = false },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = '<m-=>',
            node_incremental = '<m-=>',
            node_decremental = '<m-->',
            -- scope_incremental = '<m-0>'
          }
        },
        textobjects = {
          select = {
            lookahead = true,
            enable = true,
            keymaps = {
              ['af'] = '@function.outer',
              ['if'] = '@function.inner',
              ['ac'] = '@block.outer',
              ['ic'] = '@block.inner',
              ['aP'] = '@parameter.outer',
              ['iP'] = '@parameter.inner'
            }
          },
          move = {
            enable = true,
            set_jumps = true,

            -- NOTE(vir): remaps done manually below
          },
          swap = {
            enable = true,
            swap_next = { [']p'] = "@parameter.inner" },
            swap_previous = { ['[p'] = "@parameter.inner" }
          },
          lsp_interop = {
            enable = true,
            border = 'rounded',
            peek_definition_code = {
              ['gP'] = '@function.outer'
            }
          }
        },
        textsubjects = {
          enable = true,
          keymaps = {
            [';'] = 'textsubjects-smart',
            -- [';'] = 'textsubjects-container-outer',
          },
        },
        playground = { enable = true },
        query_linter = {
          enable = true,
          use_virtual_text = true,
          lint_events = { "BufWrite", "CursorHold" },
        },
      })

      -- go to parent
      -- utils.map('n', '[{', function()
      --     local ts = require('nvim-treesitter/ts_utils')
      --     local current = ts.get_node_at_cursor(0)
      --     local parent = current:parent()
      --     ts.goto_node(parent)
      -- end)

      -- populate all functions and lambdas into qflist
      utils.map('n', '<leader>uf', function()
        utils.qf_populate(buffer_functions(), 'r', 'Functions & Lambdas')
      end)

      -- text-subjects : move + center
      --- @format disable
      utils.map({ 'n', 'o', 'x' }, ']F',
        '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@class.outer")<CR>zz')
      utils.map({ 'n', 'o', 'x' }, '[F',
        '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@class.outer")<CR>zz')
      utils.map({ 'n', 'o', 'x' }, ']f',
        '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@function.outer")<CR>zz')
      utils.map({ 'n', 'o', 'x' }, '[f',
        '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@function.outer")<CR>zz')
      utils.map({ 'n', 'o', 'x' }, ']]',
        '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@block.outer")<CR>zz')
      utils.map({ 'n', 'o', 'x' }, '[[',
        '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@block.outer")<CR>zz')
    end
  },
  {
    'andymass/vim-matchup',
    config = function()
      vim.g.matchup_matchparen_deferred = 1
      vim.g.matchup_surround_enabled = 1
      vim.g.matchup_matchparen_offscreen = { method = 'popup' }

      local utils = require("utils")
      utils.map({ 'n', 'o', 'x' }, 'Q', '<plug>(matchup-%)')
      utils.map({ 'o', 'x' }, 'iQ', '<plug>(matchup-i%)')
      utils.map({ 'o', 'x' }, 'aQ', '<plug>(matchup-a%)')
    end
  },
  {
    'machakann/vim-sandwich',
    config = function()
      vim.g['sandwich#recipes'] = require('lib/core').list_concat(
        vim.g['sandwich#default_recipes'], {
        { buns = { '( ', ' )' }, nesting = 1, match_syntax = 1, input = { ')' } },
        { buns = { '[ ', ' ]' }, nesting = 1, match_syntax = 1, input = { ']' } },
        { buns = { '{ ', ' }' }, nesting = 1, match_syntax = 1, input = { '}' } },
      })
    end,
  },

  { 'nvim-treesitter/playground', cmd = 'TSPlaygroundToggle' },
}
