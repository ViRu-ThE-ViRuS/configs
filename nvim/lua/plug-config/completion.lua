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
--     documentation = {border = "rounded"},
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

-- nvim-cmp + luasnip setup
local cmp = require("cmp")
local luasnip = require("luasnip")

local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    print('here')
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    mapping = {
        ["<cr>"] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Replace, select = true}),
        ["<c-space>"] = cmp.mapping.complete(),
        ["<c-e>"] = cmp.mapping.close(),
        ["<c-n>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i"}),
        ["<c-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i"}),

        ["<Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif luasnip.expand_or_jumpable() then
                    luasnip.expand_or_jump()
                elseif has_words_before() then
                    cmp.complete()
                else
                    fallback()
                end
            end, {"i", "s"}),

        ["<s-tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_prev_item()
                elseif luasnip.jumpable(-1) then
                    luasnip.jump(-1)
                else
                    fallback()
                end
            end, {"i", "s"})
    },
    sources = {
        {name = "nvim_lsp"},
        {name = "treesitter"},
        {name = "luasnip"},
        {name = "path"},
        {name = "buffer", keyword_length = 3}
    },
    experimental = {
        native_menu = false,
        ghost_text = false
    },
    documentation = {
        -- border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
        border = "rounded"
    },
    formatting = {
        format = require("lspkind").cmp_format({
            with_text = true,
            menu = {
                nvim_lsp = "[lsp]",
                treesitter = "[ts]",
                luasnip = "[snip]",
                buffer = "[buf]",
                path = "[path]"
            }
        })
    }
})

cmp.setup.cmdline("/", {sources = {{name = "buffer"}}})
cmp.setup.cmdline(":", {sources = cmp.config.sources({{name = "path"}}, {{name = "cmdline", keyword_length = 3}})})

