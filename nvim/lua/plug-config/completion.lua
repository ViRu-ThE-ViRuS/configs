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
        ["<c-space>"] = cmp.mapping.complete(),
        ["<c-n>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i"}),
        ["<c-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i"}),

        ["<c-e>"] = cmp.mapping.abort(),
        ["<c-b>"] = cmp.mapping.scroll_docs(-4),
        ["<c-f>"] = cmp.mapping.scroll_docs(4),
        ["<cr>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
        }),

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
        {name = "luasnip"},
        {name = "path"},
        {name = 'rg', keyword_length = 4},
        -- {name = 'nvim_lsp_signature_help'}
        -- {name = "buffer", keyword_length = 5}
    },
    experimental = {
        native_menu = false,
        ghost_text = false
    },
    window = {
      documentation = { border = "rounded" }
    },
    formatting = {
        format = require("lspkind").cmp_format({
            with_text = true,
            menu = {
              nvim_lsp                 = "[lsp]",
              luasnip                  = "[snip]",
              rg                       = "[rg]",
              buffer                   = "[buf]",
              path                     = "[path]",
              cmdline                  = "[cmd]"
            }
        })
    }
})


cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline({}),
    sources = {{name="path"}, {name="cmdline", keyword_length=2}}
})
cmp.setup.cmdline({"/", "?"}, {
    mapping = cmp.mapping.preset.cmdline({}),
    sources = {{name="buffer"}}
})

