local cmp = require("cmp")

-- has words before cursor
local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup({
    snippet = {
        expand = function(args) require('luasnip').lsp_expand(args.body) end
    },
    mapping = {
        ["<cr>"] = cmp.mapping.confirm({behavior = cmp.ConfirmBehavior.Replace, select = false}),
        ["<c-space>"] = cmp.mapping.complete(),
        ["<c-e>"] = cmp.mapping.close(),
        ["<c-n>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i"}),
        ["<c-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i"}),

        ["<Tab>"] = cmp.mapping(
            function(fallback)
                if cmp.visible() then
                    cmp.select_next_item()
                elseif require('luasnip').expand_or_jumpable() then
                    require('luasnip').expand_or_jump()
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
                elseif require('luasnip').jumpable(-1) then
                    require('luasnip').jump(-1)
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
        {name = 'rg', keyword_length = 4},
        -- {name = "buffer", keyword_length = 5}
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
              nvim_lsp   = "[lsp]",
              treesitter = "[ts]",
              luasnip    = "[snip]",
              path       = "[path]",
              rg         = "[rg]",
              buffer     = "[buf]"
            }
        })
    }
})

cmp.setup.cmdline("/", {sources = cmp.config.sources({{name="buffer"}})})
cmp.setup.cmdline(":", {sources = cmp.config.sources({{name="path"}}, {{name="cmdline", keyword_length=2}})})

