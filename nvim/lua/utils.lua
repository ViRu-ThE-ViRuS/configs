local core = load('lib/core')

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

    -- vim.keymap.del(mode, lhs, options)
    pcall(vim.keymap.del, mode, lhs, options)
end

-- set qflist and open
local function qf_populate(lines, mode, statusline)
    if mode == nil or type(mode) == 'table' then
        lines = core.foreach(lines, function(item)
            return { filename = item, lnum = 1, col = 1, text = item }
        end)
        mode = "r"
    end

    vim.fn.setqflist(lines, mode)

    if not statusline then
        vim.cmd [[
            belowright copen
            wincmd p
        ]]
    else
        vim.cmd(string.format("belowright copen\n%s\nwincmd p", statusline))
    end
end

-- notify using current  notifications setup
local function notify(content, type, opts, force)
    if force then
        -- if packer_plugins['nvim-notify'] ~= nil and packer_plugins['nvim-notify'].loaded then
        --     require('notify')(content, type, opts)
        -- end

        require('notify')(content, type, opts)
        return
    end

    vim.notify(content, type, opts)
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

--- {{{ global states
-- lsp+ts: current tag_state [updated async]
local tag_state = {
    name = nil,
    detail = nil,
    kind = nil,
    icon = nil,
    iconhl = nil
}

-- terminal: current run_config [updated elsewhere]
local run_config = {
    target_terminal = nil,
    target_command = "",
}

-- diagnostics: toggle state
local diagnostics_state = {
    ['local'] = {},
    ['global'] = false
}

local ui_state = {
    thick_separators = false,
    window_state = {}
}
-- }}}

return {
    truncation_limit_s_terminal = 110,
    truncation_limit_s = 80,
    truncation_limit = 120,
    truncation_limit_l = 160,

    map = map,
    unmap = unmap,
    qf_populate = qf_populate,
    notify = notify,
    is_htruncated = is_htruncated,
    is_vtruncated = is_vtruncated,

    symbol_config = {
        -- indicators, icons
        indicator_seperator = '',
        indicator_hint      = '[@]',
        indicator_info      = '[i]',
        indicator_warning   = '[!]',
        indicator_error     = '[x]',

        -- signs
        sign_hint      = '@',
        sign_info      = 'i',
        sign_warning   = '!',
        sign_error     = 'x'
    },
    modes = {
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
    },
    statusline_colors = {
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
    },

    tag_state = tag_state,
    run_config = run_config,
    diagnostics_state = diagnostics_state,
    ui_state = ui_state,
}

