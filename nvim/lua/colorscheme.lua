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

vim.g.moonlight_borders = true
vim.g.vscode_style = "dark"

vim.opt.termguicolors = true
vim.opt.background = "dark"

vim.cmd [[ colorscheme jellybeans ]]

local function set_default_colorscheme()
    vim.cmd [[
        colorscheme default
        highlight VertSplit NONE
        highlight SignColumn NONE
        highlight DiffAdd NONE
        highlight DiffChange NONE
        highlight DiffDelete NONE
        highlight ColorColumn guibg=#747578
        highlight Pmenu gui=italic guifg=#FAFAFA guibg=#19191E

        highlight Identifier gui=bolditalic

        highlight DiagnosticError gui=bolditalic
        highlight DiagnosticWarn gui=bolditalic
        highlight DiagnosticInfo gui=bolditalic
        highlight DiagnosticHint gui=bolditalic

        echo 'my_default'
    ]]
end

return {
    preferred = {
        set_default_colorscheme,
        "nightfly",
        "moonfly",
        "moonlight",
        "gruvbox-material", "catppuccin",
        "everforest",
        "vscode",
        "lighthaus", "lighthaus_dark",
        "rose-pine",
        "nv-vcdark", "nv-solzdark", "nv-tokyonight",
        "meh",
        "pencil",
        "gotham",
        "pink-moon",
        "jellybeans",
        "tempus_tempest", "tempus_night",
        "base16-darkmoss", "base16-gruvbox-dark-hard", "base16-chalk",
    }
}
