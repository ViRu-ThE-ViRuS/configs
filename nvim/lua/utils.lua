local core = require('lib/core')

-- module export
M = {}

-- setup truncation limits
M.truncation_limit_s = 80
M.truncation_limit = 120
M.truncation_limit_l = 160

-- setup keymaps
M.map = function(mode, lhs, rhs, opts, buffer_nr)
    local options = { noremap = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    if buffer_nr then vim.api.nvim_buf_set_keymap(buffer_nr, mode, lhs, rhs, options)
    else vim.api.nvim_set_keymap(mode, lhs, rhs, options) end
end

-- set qflist and open
M.qf_populate = function(lines, mode)
    if mode == nil then
        lines = core.foreach(lines, function(item) return { filename = item, lnum = 1, col = 1 } end)
        mode = "r"
    end

    vim.fn.setqflist(lines, mode)
    vim.cmd [[
        copen
        setlocal statusline=%!v:lua.StatusLine('QuickFix')
        setlocal nobuflisted
        wincmd p
    ]]
end

-- randomize colorscheme
M.random_colors = function()
    local colorscheme_paths = vim.fn.globpath(vim.o.rtp, 'colors/*.vim', true, true)
    local colorschemes = core.foreach(colorscheme_paths, core.strip_fname)
    vim.cmd(string.format('colorscheme %s\ncolorscheme', colorschemes[math.random(1, #colorschemes)]))
end

-- strip trailing whitespaces in file
M.strip_trailing_whitespaces = function()
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
    indicator_hint      = '[@]',
    indicator_info      = '[i]',
    indicator_warning   = '[!]',
    indicator_error     = '[x]',

    sign_hint      = '@',
    sign_info      = 'i',
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

-- current tag_state [updated async]
M.tag_state = {
    name = nil,
    detail = nil,
    kind = nil,
    icon = nil,
    iconhl = nil
}

-- current run_config [updated elsewhere]
M.run_config = {
    target_terminal = nil,
    target_command = "",
}

return M
