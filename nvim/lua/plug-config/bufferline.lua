return {
  'akinsho/nvim-bufferline.lua',
  event = 'BufReadPre',
  opts = {
    options = {
      -- numbers = function(args) return tostring(args.id); end,
      diagnostics = false,
      buffer_close_icon = 'x',
      close_icon = 'x',
      modified_icon = '~',
      left_trunc_marker = '<',
      right_trunc_marker = '>',
      indicator = { style = 'icon', icon = '▎' },

      offsets = {
        { filetype = "NvimTree",   text = "Explorer", text_align = "center" },
        { filetype = "vista_kind", text = 'Tags',     text_align = 'center' },
        { filetype = "vista",      text = 'Tags',     text_align = 'center' }
      },

      show_tab_indicators = true,
      show_buffer_icons = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      separator_style = "thin",
      sort_by = 'id'
    }
  }
}
