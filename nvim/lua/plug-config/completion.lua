-- has words before cursor
local function has_words_before()
  if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

return {
  'hrsh7th/nvim-cmp',
  dependencies = {
    'hrsh7th/cmp-nvim-lsp',
    'onsails/lspkind-nvim',

    'L3MON4D3/LuaSnip',
    {
      "chrisgrieser/nvim-scissors",
      opts = { snippetDir = vim.fn.stdpath('config') .. '/snippets' },
      init = function()
        local utils = require('utils')
        utils.add_command('[MISC] Add New Snippet', function()
          vim.cmd('normal! gv')
          require('scissors').addNewSnippet()
        end, { add_custom = true })
        utils.add_command('[MISC] Edit Snippets', function() require('scissors').editSnippet() end, { add_custom = true })
      end
    },

    'saadparwaiz1/cmp_luasnip',
    'hrsh7th/cmp-nvim-lua',
    'hrsh7th/cmp-path',
    'lukas-reineke/cmp-rg',
    'hrsh7th/cmp-buffer',
    'hrsh7th/cmp-cmdline',
    { 'zbirenbaum/copilot-cmp',     opts = {} }
  },
  event = 'InsertEnter',
  config = function()
    -- NOTE(vir): from https://github.com/zbirenbaum/copilot-cmp
    require('lspkind').init({
      symbol_map = {
        Copilot = '[ai]',
        ['copilot-chat'] = '[ai]',
      }
    })

    -- NOTE(vir): from https://github.com/chrisgrieser/nvim-scissors
    require("luasnip.loaders.from_vscode").lazy_load {
      paths = { vim.fn.stdpath('config') .. '/snippets' },
    }

    local cmp = require("cmp")
    cmp.setup({
      snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
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
            local luasnip = require('luasnip')

            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
            else
              fallback()
            end
          end, { "i", "s" }),

        ["<s-tab>"] = cmp.mapping(
          function(fallback)
            local luasnip = require('luasnip')

            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" })
      },
      sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = 'nvim_lua' },
        { name = "path" },
        { name = "copilot" },
        { name = "copilot-chat" },
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
            luasnip          = "[snip]",
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
  end
}
