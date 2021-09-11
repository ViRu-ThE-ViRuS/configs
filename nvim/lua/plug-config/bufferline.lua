require('bufferline').setup {
    options = {
        numbers = function(args) return args.id; end,
        diagnostics = false,
        indicator_icon = '▎',
        buffer_close_icon = 'x',
        close_icon = 'x',
        modified_icon = '~',
        left_trunc_marker = '<',
        right_trunc_marker = '>',

        offsets = {
            {filetype = "NvimTree", text = "Explorer", text_align = "center"},
            {filetype = "tagbar", text = 'Tagbar', text_align = 'center'},
            {filetype = "Outline", text = 'Outline', text_align = 'center'},
            {filetype = "vista", text = 'Vista', text_align = 'center'},
        },

        show_tab_indicators = true,
        show_buffer_icons = true,
        show_buffer_close_icons = false,
        show_close_icon = false,
        enforce_regular_tabs = false,
        always_show_bufferline = true,
        separator_style = "thin",
    }
}

