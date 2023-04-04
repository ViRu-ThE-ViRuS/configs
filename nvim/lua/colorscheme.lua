vim.g.barstrata_italic_booleans = true
vim.g.barstrata_italic_functions = true
vim.g.barstrata_italic_keywords = true
vim.g.barstrata_variant = "default"

vim.g.everforest_background = "hard"
vim.g.everforest_better_performance = 1
vim.g.everforest_diagnostic_text_highlight = 1
vim.g.everforest_diagnostic_virtual_text = "colored"
vim.g.everforest_enable_italic = 1
vim.g.everforest_sign_column_background = "none"
vim.g.everforest_ui_contrast = "high"

vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_diagnostic_text_highlight = 1
vim.g.gruvbox_material_diagnostic_virtual_text = "colored"
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_material_sign_column_background = "none"
vim.g.gruvbox_material_ui_contrast = "high"

vim.g.mellow_bold_comments = true
vim.g.mellow_bold_functions = true
vim.g.mellow_italic_booleans = true
vim.g.mellow_italic_functions = true
vim.g.mellow_italic_keywords = true

vim.g.moonflyItalics = 1
vim.g.moonflyNormalFloat = 1
vim.g.moonflyTerminalColors = 1
vim.g.moonflyUnderlineMatchParen = 1
vim.g.moonflyVertSplits = 1

vim.g.gruvbox_baby_background_color = "medium"
vim.g.material_style = "oceanic"
vim.g.tempus_enforce_background_color = 1
vim.g.vscode_style = "dark"

-- {{{ lua configured colorscheme loaders
local function load_material(variant)
  return function(_)
    require('material').setup({
      styles = {
        comments = { italic = true },
        functions = { italic = true },
        strings = { italic = true }
      }
    })

    vim.g.material_style = variant
    vim.cmd.colorscheme('material')
    return string.format('material [%s]', variant)
  end
end

local function load_nightfox(variant)
  return function(_)
    require('nightfox').setup({
      options = {
        terminal_colors = true,
        inverse = { search = true },
        styles = {
          comments = "bold,italic",
          functions = "bold,italic",
          strings = "italic",
        }
      }
    })

    vim.cmd.colorscheme(variant)
    return string.format('nightfox [%s]', variant)
  end
end

local function load_catppuccin(variant)
  return function(_)
    require("catppuccin").setup({
      flavor = "mocha",
      term_colors = true,
      transparent_background = false,
      styles = {
        comments = { "bold", "italic" },
        functions = { "bold", "italic" },
        numbers = { "underline" },
        strings = { "italic" },
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        bufferline = true,
        notify = true,
        treesitter = true,
        native_lsp = {
          enabled = true,
          virtual_text = {
            errors = { "bold", "italic" },
            hints = { "italic" },
            warnings = { "italic" },
            information = { "italic" },
          },
          underlines = {
            errors = { "underline" },
            hints = { "underline" },
            warnings = { "underline" },
            information = { "underline" },
          },
        },
        nvimtree = { enabled = true, show_root = true },
        dap = { enabled = true, enable_ui = true },
      },
    })

    vim.cmd.colorscheme(variant)
    return string.format('catppuccin [%s]', variant)
  end
end

local function load_rose_pine(variant)
  return function()
    require('rose-pine').setup({
      dark_variant = variant
    })

    vim.cmd.colorscheme('rose-pine')
    return string.format('rose-pine [%s]', variant or 'dawn')
  end
end

-- }}}

-- {{{ overrides
-- setup colorscheme overrides
local function ui_overrides()
  -- set normal to a default if not already set
  if vim.api.nvim_get_hl_by_name("Normal", true).background == nil then
    vim.api.nvim_set_hl(0, "Normal", { background = 0x171717 })
    vim.api.nvim_set_hl(0, "NormalFloat", { background = 0x171717 })
  end

  vim.opt.guicursor = 'n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor'
  vim.opt.hlsearch = false

  -- NOTE(vir): some colorschemes aint pretty with gitsigns
  -- GitSign* highlights link to Diff* highlights for some reason despite
  -- configuring them not to. Consider linking these only when in git repos?
  vim.cmd([[
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

        " statuscolumn
        highlight! link LineNr Normal
        highlight! link SignColumn Normal
        highlight! link FoldColumn Normal
        highlight! link CursorLineNr CursorLine
        highlight! link CursorLineFold CursorLine
        highlight! link CursorLineSign CursorLine

        " misc
        highlight! link VertSplit Normal
        highlight! link FloatBorder Normal
        highlight! link NormalFloat Normal
    ]])

  -- set statusline highlights
  -- NOTE(vir): this will also initialize and set the statusline on first call
  require('statusline').setup_highlights()
end

-- }}}

vim.opt.termguicolors = true
vim.opt.background = 'dark'

local colorscheme = 'gruvbox'
---@cast colorscheme +string +function

-- load default colorscheme if chosen one is not available
local set_fn = ((type(colorscheme) == 'function' and colorscheme) or vim.cmd.colorscheme)
if not pcall(set_fn, colorscheme) then vim.cmd.colorscheme('default') end

-- initial call
ui_overrides()

return {
  preferred = {
    dark = {
      "aquarium",
      "barstrata",
      "danger",
      "everforest",
      "gruvbox",
      "gruvbox-baby",
      "gruvbox-material",
      "habamax",
      "melange",
      "mellow",
      "monokai_pro", "monokai_ristretto",
      "moonfly",
      "mountain",
      "nightfly",
      "noctis", "noctis_bordo", "noctis_minimus", "noctis_uva",
      "oxocarbon",
      "palenightfall",
      "poimandres",
      "sweetie",
      "tempus_tempest", "tempus_dusk",
      "vscode",
      "xcodedarkhc",
      "default",

      -- lua configured colorschemes
      load_catppuccin('catppuccin-frappe'),
      load_catppuccin('catppuccin-macchiato'),
      load_catppuccin('catppuccin-mocha'),
      load_material('darker'),
      load_material('palenight'),
      load_nightfox('carbonfox'),
      load_nightfox('duskfox'),
      load_nightfox('nightfox'),
      load_nightfox('nordfox'),
      load_nightfox('terafox'),
      load_rose_pine('main'),
      load_rose_pine('moon'),
    },

    -- NOTE(vir): Yes, sometimes, i use light themes,
    -- they remind me of the pain that exists in the world :o
    light = {
      "everforest",
      "gruvbox",
      "gruvbox-material",
      "intellij",
      "oxocarbon",
      "sweetie",
      "tempus_dawn", "tempus_totus",
      "vscode",
      "xcodelighthc",
      "shine",

      -- lua configured colorschemes
      load_catppuccin("catppuccin-latte"),
      load_material('lighter'),
      load_nightfox('dawnfox'),
      load_rose_pine(),
    }
  },
  ui_overrides = ui_overrides,
}
