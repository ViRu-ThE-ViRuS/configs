M = {}

-- setup truncation limits
M.truncation_limit_s = 80
M.truncation_limit = 120
M.truncation_limit_l = 160

-- setup keymaps
M.map = function (mode, lhs, rhs, opts, buffer_nr)
    local options = { noremap = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    if buffer_nr then vim.api.nvim_buf_set_keymap(buffer_nr, mode, lhs, rhs, options)
    else vim.api.nvim_set_keymap(mode, lhs, rhs, options) end
end

-- randomize colorscheme
M.RandomColors = function()
    vim.cmd [[
    colorscheme random
    colorscheme
    ]]
end

-- strip trailing whitespaces in file
M.StripTrailingWhitespaces = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_command('%s/\\s\\+$//e')
    vim.api.nvim_win_set_cursor(0, cursor)
end

-- is buffer horizontally truncated
M.is_htruncated = function(width)
  local current_width = vim.api.nvim_win_get_width(0)
  return current_width < width
end

-- is buffer verticall truncated
M.is_vtruncated = function(height)
  local current_height = vim.api.nvim_win_get_height(0)
  return current_height < height
end

-- diagnostics symbol config
M.symbol_config = {
    indicator_seperator = '',
    indicator_info      = '[i]',
    indicator_hint      = '[@]',
    indicator_warning   = '[!]',
    indicator_error     = '[x]',

    sign_info      = 'i',
    sign_hint      = '@',
    sign_warning   = '!',
    sign_error     = 'x'
}


-- mode display name table
M.modes = {
    ['n']  = 'Normal',
    ['no'] = 'N-Pending',
    ['v']  = 'Visual',
    ['V']  = 'V-Line',
    [''] = 'V-Block',
    ['s']  = 'Select',
    ['S']  = 'S-Line',
    [''] = 'S-Block',
    ['i']  = 'Insert',
    ['ic'] = 'Insert',
    ['R']  = 'Replace',
    ['Rv'] = 'V-Replace',
    ['c']  = 'Command',
    ['cv'] = 'Vim-Ex ',
    ['ce'] = 'Ex',
    ['r']  = 'Prompt',
    ['rm'] = 'More',
    ['r?'] = 'Confirm',
    ['!']  = 'Shell',
    ['t']  = 'Terminal'
}

-- statusline colors
M.statusline_colors = {
    active      = '%#StatusLine#',
    inactive    = '%#StatusLineNC#',
    mode        = '%#PmenuSel#',
    git         = '%#Pmenu#',
    diagnostics = '%#PmenuSbar#',
    file        = '%#CursorLine#',
    tagname     = '%#PmenuSbar#',
    line_col    = '%#CursorLine#',
    percentage  = '%#CursorLine#',
    filetype    = '%#PmenuSel#',
}

-- current TagState [updated async]
M.TagState = {
    name = nil,
    detail = nil,
    kind = nil,
    icon = nil,
    iconhl = nil
}

return M
