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

require('nightfox').setup({
    fox = "nightfox",
    styles = {comments = "italic", keywords = "bold", functions = "italic,bold"}
})

vim.g.moonflyItalics = 1
vim.g.moonflyNormalFloat = 1
vim.g.moonflyTerminalColors = 1
vim.g.moonflyUnderlineMatchParen = 1

vim.g.vscode_style = "dark"

vim.opt.termguicolors = true
vim.opt.background = "dark"

-- can takeup a lot of startup time
-- vim.defer_fn(function()
    vim.cmd [[ colorscheme default ]]
-- end, 0)

-- gruvbox deus everforest
-- nord OceanicNext quantum neodark moonlight
-- bluewery Tomorrow-Night-Blue tokyonight rigel adventurous
-- Tomorrow-Night-Eighties apprentice luna CandyPaper jellybeans
-- materialbox solarized8_dark_high moonlight nightfly
-- antares codedark desertink default moonfly
-- aquamarine oceanblack ir_black
--
-- base16-black-metal-bathory gruvbox-material
-- moonlight nightfly moonfly codedark everforest
-- zephyr vscode base16-darktooth base16-apprentice
-- base16-gruvbox-light-hard base16-outrun-dark
--
-- cake16 solarized8_light_high
-- Tomorrow eclipse autumnleaf aurora White2
--
-- lighthaus tempus_tempest vscode nightfox moonfly everforest gruvbox-material
-- base16-darkmoss


