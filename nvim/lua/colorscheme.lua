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

vim.g.rasmus_italic_keywords = true
vim.g.rasmus_italic_booleans = true
vim.g.rasmus_italic_functions = true

vim.g.gruvbox_baby_background_color = 'medium'
vim.g.vscode_style = "dark"
vim.g.material_style = "darker"

-- {{{ material
-- require('material').setup({
--     italics = {
--         comments = true,
--         functions = true,
--         strings = true
--     }
-- })
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

-- {{{ overrides
-- setup colorscheme overrides
local function ui_overrides()
    -- vim.highlight.create('Comment', {cterm = 'bold,italic', gui = 'bold,italic'}, false)
    -- vim.highlight.create('LineNr', {cterm = 'NONE', gui = 'NONE'}, false)

    -- TODO(vir): do this in lua
    -- NOTE(vir): some colorschemes aint pretty with gitsigns
    -- GitSign* highlights link to Diff* highlights for some reason despite
    -- configuring them not to. Consider linking these only when in git repos?
    vim.cmd [[
        " Misc
        highlight! link SignColumn LineNr
        highlight! link VertSplit LineNr
        highlight! link FloatBorder Normal
        highlight! link NormalFloat Normal

        " gitsigns
        highlight! link GitSignsAdd GitGutterAdd
        highlight! link GitSignsChange GitGutterChange
        highlight! link GitSignsDelete GitGutterDelete
    ]]
end
-- }}}

vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.cmd [[ colorscheme substrata ]]
ui_overrides()

return {
    preferred = {
        "nightfly",
        "nightfox", "duskfox", "nordfox", "terafox",
        "kanagawa",
        "material",
        "moonfly",
        "gruvbox-material",
        "gruvbox-baby",
        "catppuccin",
        "rasmus",
        "adwaita",
        "everforest",
        "vscode",
        "rose-pine",
        "substrata",
        "monokai", "monokai_pro",
        "jellybeans",
        "mountain",
        "saturnite",
        "tempus_tempest", "tempus_spring",
        "base16-apprentice", "base16-ashes",
        "base16-monokai",

        -- NOTE(vir): light themes. Yes, sometimes, i like light themes, they
        -- remind me of the pain that exists in the world :o
        -- "tempus_totus",
    },
    ui_overrides = ui_overrides
}

