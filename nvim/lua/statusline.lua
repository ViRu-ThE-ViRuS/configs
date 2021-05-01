local colors = {
    active     = '%#StatusLine#',
    inactive   = '%#StatuslineNC#',
    mode       = '%#PmenuSel#',
    git        = '%#Pmenu#',
    file       = '%#CursorLine#',
    tagname    = '%#Pmenu#',
    line_col   = '%#CursorLine#',
    percentage = '%#CursorLine#',
    filetype   = '%#Pmenu#',
}

local modes = setmetatable({
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
}, {
    __index = function()
      return 'Unknown'
    end
})

local get_current_mode = function()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format(' %s ', modes[current_mode]):upper()
end

local get_git_status = function()
    local meta = {}
    meta['branch'] = vim.fn['fugitive#head']()

    local git_summary = vim.fn['GitGutterGetHunkSummary']()
    meta['added'] = git_summary[1]
    meta['modified'] = git_summary[2]
    meta['removed'] = git_summary[3]

    if meta['branch'] == '' then
        return ''
    else
        return string.format(' %s | +%s ~%s -%s ', meta['branch'], meta['added'], meta['modified'], meta['removed'])
    end
end

local get_tag_name = function()
    return vim.fn['tagbar#currenttag']('[%s]', '')
end

local get_filename = function()
    return ' %<%f '
end

local get_line_col = function()
    return ' %l:%c '
end

local get_percentage = function()
    return '%p%% '
end

local get_filetype = function()
    return '%y'
end

Statusline = function()
    local mode = colors.mode .. get_current_mode()
    local git = colors.git .. get_git_status()
    local filename = colors.file .. get_filename()
    local tagname = colors.tagname .. get_tag_name()
    local line_col = colors.line_col .. get_line_col()
    local percentage = colors.percentage .. get_percentage()
    local filetype = colors.filetype .. get_filetype()

    return table.concat({
        colors.active, mode, git, filename,
        '%=% ',
        tagname, line_col, percentage,  filetype
    })
end

vim.cmd [[
set statusline=%!v:lua.Statusline()
]]
