vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_contrast_dark = "hard"
vim.g.gruvbox_contrast_light = "hard"
vim.g.gruvbox_material_ui_contrast = "high"
vim.g.gruvbox_material_sign_column_background = "none"
vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
vim.g.gruvbox_material_diagnostic_text_highlight = 1
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_enable_italic = 1

vim.g.everforest_background = "hard"
vim.g.everforest_ui_contrast = "high"
vim.g.everforest_sign_column_background = "none"
vim.g.everforest_diagnostic_virtual_text = "colored"
vim.g.everforest_diagnostic_text_highlight = 1
vim.g.everforest_better_performance = 1
vim.g.everforest_enable_italic = 1

vim.g.moonflyItalics = 1
vim.g.moonflyNormalFloat = 1
vim.g.moonflyTerminalColors = 1
vim.g.moonflyUnderlineMatchParen = 1
vim.g.moonflyVertSplits = 1

vim.g.substrata_italic_keywords = true
vim.g.substrata_italic_booleans = true
vim.g.substrata_italic_functions = true
vim.g.substrata_variant = "default"

vim.g.gruvbox_baby_background_color = 'medium'
vim.g.vscode_style = "dark"
vim.g.material_style = "oceanic"

-- {{{ material
require('material').setup({
    italics = {
        comments = true,
        functions = true,
        strings = true
    },
})
-- }}}

-- {{{ nightfox
-- require('nightfox').setup({
--     options = {
--         terminal_colors = true,
--         inverse = { search = true },
--         styles = {
--             comments = "bold,italic",
--             functions = "bold,italic",
--             strings = "italic",
--         },
--         modules = {
--             cmp        = true,
--             gitsigns   = true,
--             treesitter = true,
--             diagnostic = true,
--             native_lsp = {
--                 enabled = true,
--                 virtual_text = {
--                     errors = "bold,italic",
--                     hints = "italic",
--                     warnings = "italic",
--                     information = "italic",
--                 },
--                 underlines = {
--                     errors = "underline",
--                     hints = "underline",
--                     warnings = "underline",
--                     information = "underline",
--                 },
--             },
--             nvimtree   = {
--                 enabled = true,
--                 show_root = true,
--             },
--         }
--     }
-- })
-- }}}

-- {{{ catppuccin
-- require('catppuccin').setup({
--     term_colors = true,
--     styles = {
--         comments = "bold,italic",
--         functions = "bold,italic",
--         numbers = "underline",
--         strings = "italic",
--     },
--     integrations = {
--         cmp = true,
--         gitsigns = true,
--         bufferline = true,
--         notify = true,
--         treesitter = true,
--         native_lsp = {
--             enabled = true,
--             virtual_text = {
--                 errors = "bold,italic",
--                 hints = "italic",
--                 warnings = "italic",
--                 information = "italic",
--             },
--             underlines = {
--                 errors = "underline",
--                 hints = "underline",
--                 warnings = "underline",
--                 information = "underline",
--             },
--         },
--         nvimtree = {
--             enabled = true,
--             show_root = true,
--         },
--     }
-- })
-- }}}

vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.cmd [[ colorscheme gruvbox-material ]]

return {
    preferred = {
        "nightfly",
        "nightfox", "duskfox", "nordfox",
        "kanagawa",
        "material",
        "moonfly",
        "gruvbox-material",
        "gruvbox-baby",
        "catppuccin",
        "everforest",
        "vscode",
        "rose-pine",
        "substrata",
        "monokai", "monokai_pro",
        "jellybeans",
        "mountain",
        "saturnite",
        "tempus_tempest",
        "base16-apprentice", "base16-ashes",
        "base16-monokai"
    }
}

