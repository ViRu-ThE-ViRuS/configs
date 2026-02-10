-- has words before cursor
local function has_words_before()
  if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function setup_lspkind()
  -- NOTE(vir): from https://github.com/zbirenbaum/copilot-cmp
  require('lspkind').init({
    symbol_map = {
      Copilot = '[ai]',
      ['copilot-chat'] = '[ai]',
      ['lsp'] = '[lsp]',
    }
  })
end

local function setup_scissors()
  local utils = require('utils')
  utils.add_command('[MISC] Add New Snippet', function()
    vim.cmd('normal! gv')
    require('scissors').addNewSnippet()
  end, { add_custom = true })
  utils.add_command('[MISC] Edit Snippets', function() require('scissors').editSnippet() end, { add_custom = true })
end

return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    {
      'onsails/lspkind-nvim',
      config = setup_lspkind,
    },

    { 'rafamadriz/friendly-snippets' },
    {
      'garymjr/nvim-snippets',
      opts = { friendly_snippets = true, search_paths = { vim.fn.stdpath('config') .. '/snippets' } },
    },
    {
      "chrisgrieser/nvim-scissors",
      opts = { snippetDir = vim.fn.stdpath('config') .. '/snippets' },
      config = setup_scissors,
    },

    'hrsh7th/cmp-nvim-lsp',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-path',
    'lukas-reineke/cmp-rg',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',

    {
      'zbirenbaum/copilot-cmp',
      opts = {},
    }
  },
  event = 'InsertEnter',
  config = function()
    local cmp = require("cmp")
    cmp.setup({
      snippet = { expand = function(args) vim.snippet.expand(args.body) end },
      mapping = {
        ["<c-space>"] = cmp.mapping.complete(),
        ["<c-n>"] = cmp.mapping(cmp.mapping.select_next_item(), { "i" }),
        ["<c-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), { "i" }),

        ["<c-e>"] = cmp.mapping.abort(),
        ["<c-b>"] = cmp.mapping.scroll_docs(-4),
        ["<c-f>"] = cmp.mapping.scroll_docs(4),
        ["<cr>"] = cmp.mapping.confirm({
          behavior = cmp.ConfirmBehavior.Replace,
          select = false,
        }),

        ["<Tab>"] = cmp.mapping(
          function(fallback)
            if vim.snippet.active({ direction = 1 }) then
              vim.snippet.jump(1)
            elseif cmp.visible() then
              cmp.select_next_item()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

        ["<s-tab>"] = cmp.mapping(
          function(fallback)
            if vim.snippet.active({ direction = -1 }) then
              vim.snippet.jump(-1)
            elseif cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" })
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "snippets" },
        { name = 'nvim_lua' },
        { name = "path" },
        { name = "copilot" },
      }, {
        { name = 'rg', keyword_length = 4 },
        -- { name = 'buffer', keyword_length = 4 },
      }),
      experimental = { native_menu = false, ghost_text = false },
      window = { documentation = { border = "rounded" } },
      formatting = {
        format = require("lspkind").cmp_format({
          with_text = true,
          menu = {
            nvim_lsp         = "[lsp]",
            snippets         = "[snip]",
            nvim_lua         = '[nvim]',
            path             = "[path]",
            rg               = "[rg]",
            buffer           = "[buf]",
            cmdline          = "[cmd]",
            copilot          = "[copilot]",
            ['copilot-chat'] = "[copilot-chat]",
          }
        })
      }
    })

    cmp.setup.cmdline(":", {
      mapping = cmp.mapping.preset.cmdline({}),
      sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline", keyword_length = 2 } })
    })

    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline({}),
      sources = { { name = "buffer" } }
    })

    cmp.setup.filetype({ "copilot-chat" }, {
      sources = {
        { name = "rg" },
        { name = "copilot" },
        { name = "copilot-chat" },
      }
    })
  end
}
