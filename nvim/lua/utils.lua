local core = require('lib/core')

-- setup keymaps
local function map(mode, lhs, rhs, opts, buffer_nr)
    local options = { noremap = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    if buffer_nr then options['buffer'] = buffer_nr end

    vim.keymap.set(mode, lhs, rhs, options)
end

-- remove keymaps
local function unmap(mode, lhs, buffer_nr)
    local options = {}
    if buffer_nr then options['buffer'] = buffer_nr end

    vim.keymap.del(mode, lhs, options)
end

-- set qflist and open
local function qf_populate(lines, mode)
    if mode == nil or type(mode) == 'table' then
        lines = core.foreach(lines, function(item)
            return { filename = item, lnum = 1, col = 1, text = item }
        end)
        mode = "r"
    end

    vim.fn.setqflist(lines, mode)

    vim.cmd [[
        copen
        wincmd p
    ]]
end

-- randomize colorscheme
local function random_colors()
    -- local colorscheme_paths = vim.fn.globpath(vim.o.rtp, 'colors/*.vim', true, true)
    -- local colorschemes = core.foreach(colorscheme_paths, misc.strip_fname)

    local colorschemes = require('colorscheme').preferred
    local target = colorschemes[math.random(1, #colorschemes)]

    if type(target) == 'function' then
        target()
    else
        vim.cmd(string.format('colorscheme %s\ncolorscheme', target))
    end
end

-- strip trailing whitespaces in file
local function strip_trailing_whitespaces()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_command('%s/\\s\\+$//e')
    vim.api.nvim_win_set_cursor(0, cursor)
end

-- flash cursorline
-- NOTE(vir): this gets "stuck" in new color
local function flash_cursorline()
    local current = vim.api.nvim_get_hl_by_name("CursorLine", true)
    local target = vim.api.nvim_get_hl_by_name("IncSearch", true)

    vim.api.nvim_set_hl(0, "CursorLine", target)
    vim.defer_fn(function() vim.api.nvim_set_hl(0, "CursorLine", current) end, 200)
end

-- is buffer horizontally truncated
local function is_htruncated(width)
    local current_width = vim.api.nvim_win_get_width(0)
    return current_width < width
end

-- is buffer vertical truncated
local function is_vtruncated(height)
    local current_height = vim.api.nvim_win_get_height(0)
    return current_height < height
end

-- diagnostics symbol config
local symbol_config = {
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
local modes = {
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
local statusline_colors = {
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
local tag_state = {
    name = nil,
    detail = nil,
    kind = nil,
    icon = nil,
    iconhl = nil
}

-- current run_config [updated elsewhere]
local run_config = {
    target_terminal = nil,
    target_command = "",
}

return {
    truncation_limit_s_terminal = 110,
    truncation_limit_s = 80,
    truncation_limit = 120,
    truncation_limit_l = 160,

    map = map,
    unmap = unmap,
    qf_populate = qf_populate,
    random_colors = random_colors,
    strip_trailing_whitespaces = strip_trailing_whitespaces,
    flash_cursorline = flash_cursorline,
    is_htruncated = is_htruncated,
    is_vtruncated = is_vtruncated,

    symbol_config = symbol_config,
    modes = modes,
    statusline_colors = statusline_colors,
    tag_state = tag_state,
    run_config = run_config
}

