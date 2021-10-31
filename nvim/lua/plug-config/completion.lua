-- nvim-compe setup
-- local utils = require("utils")

-- require("compe").setup {
--     debug = false,
--     enabled = true,
--     autocomplete = true,
--     min_length = 1,
--     preselect = "enable",
--     max_abbr_width = 100,
--     max_kind_width = 100,
--     max_menu_width = 100,
--     documentation = {border = "single"},
--     source = {
--         path = true,
--         buffer = true,
--         calc = true,
--         nvim_lsp = true,
--         nvim_lua = true
--     }
-- }

-- utils.map("i", "<c-space>", "compe#complete()", {silent = true, expr = true})
-- utils.map("i", "<cr>", 'compe#confirm("<cr>")', {silent = true, expr = true})
-- utils.map("i", "<c-e>", 'compe#close("<c-e>")', {silent = true, expr = true})


-- nvim-cmp setup
local cmp = require('cmp')

cmp.setup({
    snippet = {},
    mapping = {
      ['<cr>'] = cmp.mapping.confirm({ select = true, behaviour = cmp.ConfirmBehavior.Replace }),
      ['<c-space>'] = cmp.mapping.complete(),
      ['<c-e>'] = cmp.mapping.close(),
      ['<c-n>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i' }),
      ['<c-p>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i' }),
      ['<tab>'] = cmp.mapping(cmp.mapping.select_next_item(), { 'i', 's' }),
      ['<s-tab>'] = cmp.mapping(cmp.mapping.select_prev_item(), { 'i', 's' })
    },
    sources = {
      { name = 'nvim_lsp' },
      { name = 'treesitter' },
      { name = 'path' },
      { name = 'buffer', keyword_length = 3 }
    },
    experimental = {
        native_menu = false,
        ghost_text = false,
    },
    documentation = {
        border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
        -- border = 'single'
    },
    formatting = {
        format = require("lspkind").cmp_format({
            with_text = true,
            menu = {
                nvim_lsp = "[lsp]",
                treesitter = "[ts]",
                buffer = "[buf]",
                path = '[path]'
            }
            }),
    },
})

