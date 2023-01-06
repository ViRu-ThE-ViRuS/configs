vim.g.gruvbox_material_background = "hard"
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

vim.g.barstrata_italic_keywords = true
vim.g.barstrata_italic_booleans = true
vim.g.barstrata_italic_functions = true
vim.g.barstrata_variant = "default"

vim.g.rasmus_italic_keywords = true
vim.g.rasmus_italic_booleans = true
vim.g.rasmus_italic_functions = true

vim.g.mellow_italic_keywords = true
vim.g.mellow_italic_booleans = true
vim.g.mellow_italic_functions = true
vim.g.mellow_bold_functions = true
vim.g.mellow_bold_comments = true

vim.g.oh_lucy_italic_keywords = true
vim.g.oh_lucy_italic_booleans = true
vim.g.oh_lucy_italic_functions = true
vim.g.oh_lucy_evening_italic_keywords = true
vim.g.oh_lucy_evening_italic_booleans = true
vim.g.oh_lucy_evening_italic_functions = true

vim.g.gruvbox_baby_background_color = "medium"
vim.g.tempus_enforce_background_color = 1
vim.g.embark_terminal_italics = 1
vim.g.vscode_style = "dark"
vim.g.material_style = "darker"

-- {{{ material
-- require('material').setup({
--     styles = {
--         comments = { italic = true },
--         functions = { italic = true },
--         strings = { italic = true }
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
-- require("catppuccin").setup({
--  flavor = "mocha",
-- 	term_colors = true,
-- 	transparent_background = false,
-- 	styles = {
-- 		comments = { "bold", "italic" },
-- 		functions = { "bold", "italic" },
-- 		numbers = { "underline" },
-- 		strings = { "italic" },
-- 	},
-- 	integrations = {
-- 		cmp = true,
-- 		gitsigns = true,
-- 		bufferline = true,
-- 		notify = true,
-- 		treesitter = true,
-- 		native_lsp = {
-- 			enabled = true,
-- 			virtual_text = {
-- 				errors = { "bold", "italic" },
-- 				hints = { "italic" },
-- 				warnings = { "italic" },
-- 				information = { "italic" },
-- 			},
-- 			underlines = {
-- 				errors = { "underline" },
-- 				hints = { "underline" },
-- 				warnings = { "underline" },
-- 				information = { "underline" },
-- 			},
-- 		},
-- 		nvimtree = { enabled = true, show_root = true },
-- 		dap = { enabled = true, enable_ui = true },
-- 	},
-- })
-- }}}

-- {{{ overrides
-- setup colorscheme overrides
local function ui_overrides()
    -- set normal to a default if not already set
    if vim.api.nvim_get_hl_by_name("Normal", true).background == nil then
        vim.api.nvim_set_hl(0, "Normal", { background = 0x171717 })
    end

    vim.opt.guicursor = 'n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor'
    vim.opt.hlsearch = false

    -- NOTE(vir): some colorschemes aint pretty with gitsigns
    -- GitSign* highlights link to Diff* highlights for some reason despite
    -- configuring them not to. Consider linking these only when in git repos?
    vim.cmd [[
        " lsp
        highlight! link LspReferenceRead IncSearch
        highlight! link LspReferenceWrite IncSearch
        highlight! clear LspReferenceText

        " make comments bold, italic
        highlight! Comment gui=bold,italic
        highlight! link @comment Comment

        " diagnostics
        highlight! DiagnosticError guibg=NONE
        highlight! DiagnosticWarn guibg=NONE
        highlight! DiagnosticInfo guibg=NONE
        highlight! DiagnosticHint guibg=NONE
        highlight! DiagnosticUnderlineError gui=bold,underline
        highlight! DiagnosticUnderlineWarn gui=bold,underline
        highlight! DiagnosticUnderlineInfo gui=bold,underline
        highlight! DiagnosticUnderlineHint gui=bold,underline

        " gitsigns
        highlight! link GitSignsAdd GitGutterAdd
        highlight! link GitSignsChange GitGutterChange
        highlight! link GitSignsDelete GitGutterDelete

        " misc
        highlight! link SignColumn LineNr
        highlight! link FoldColumn LineNr
        highlight! link VertSplit LineNr
        highlight! link FloatBorder Normal
        highlight! link NormalFloat Normal
    ]]

    -- set statusline highlights
    require('statusline').setup_highlights()
end
-- }}}

vim.opt.termguicolors = true
vim.opt.background = 'dark'
local colorscheme = 'nightfox'

-- load default colorscheme if chosen one is not available
if not pcall(vim.cmd.colorscheme, colorscheme) then vim.cmd.colorscheme('default') end
ui_overrides()

return {
    preferred = {
        dark = {
            "nightfly",
            "nightfox", "duskfox", "nordfox", "terafox", "carbonfox",
            "tundra",
            "material",
            "moonfly",
            "poimandres",
            "gruvbox-material",
            "gruvbox-baby",
            "gruvbox",
            "mellow",
            "oxocarbon-lua",
            "rasmus",
            "adwaita",
            "everforest",
            "vscode",
            "barstrata",
            "substrata",
            "monokai_pro", "monokai_ristretto",
            "mountain",
            "catppuccin", "catppuccin-macchiato",
            "rose-pine",
            "habamax",
            "xcodedark",
            "tempus_tempest",
            "default",
        },

        -- NOTE(vir): Yes, sometimes, i use light themes,
        -- they remind me of the pain that exists in the world :o
        light = {
            "dawnfox",
            "gruvbox-material",
            "gruvbox",
            "adwaita",
            "everforest",
            "vscode",
            "catppuccin-latte",
            "rose-pine",
            "xcodelight",
            "intellij",
            "shine",
        }
    },
    ui_overrides = ui_overrides,
}

