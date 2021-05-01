local lsp_status = require('lsp-status')

local colors = {
    active      = '%#StatusLine#',
    inactive    = '%#StatuslineNC#',
    mode        = '%#PmenuSel#',
    git         = '%#Pmenu#',
    file        = '%#CursorLine#',
    diagnostics = '%#PmenuSel#',
    tagname     = '%#Pmenu#',
    line_col    = '%#CursorLine#',
    percentage  = '%#CursorLine#',
    filetype    = '%#Pmenu#',
}

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
    return vim.fn['tagbar#currenttag'](' [%s] ', '')
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
    return ' %y '
end

local config = {
    indicator_errors = '[x]',
    indicator_warnings = '[!]',
    indicator_info = '[i]',
    indicator_hint = '[@]',
    indicator_seperator = ''
}
local get_diagnostics = function()
    if #vim.lsp.buf_get_clients(0) == 0 then return '' end

    local status_parts = {}
    local diagnostics = lsp_status.diagnostics(0) or nil

    if diagnostics then
        if diagnostics.errors and diagnostics.errors > 0 then
            table.insert(status_parts, config.indicator_errors .. config.indicator_seperator .. diagnostics.errors)
        end

        if diagnostics.warnings and diagnostics.warnings > 0 then
            table.insert(status_parts, config.indicator_warnings .. config.indicator_seperator .. diagnostics.warnings)
        end

        if diagnostics.info and diagnostics.info > 0 then
            table.insert(status_parts, config.indicator_info .. config.indicator_seperator .. diagnostics.info)
        end

        if diagnostics.hints and diagnostics.hints > 0 then
            table.insert(status_parts, config.indicator_hint .. config.indicator_seperator .. diagnostics.hints)
        end
    end

    local status_diagnostics = vim.trim(table.concat(status_parts, '  '))
    if status_diagnostics ~= '' then return ' ' .. status_diagnostics .. ' ' end
    return ''
end

Statusline = function()
    local mode = colors.mode .. get_current_mode()
    local git = colors.git .. get_git_status()
    local filename = colors.file .. get_filename()
    local diagnostics = colors.diagnostics .. get_diagnostics()
    local tagname = colors.tagname .. get_tag_name()
    local line_col = colors.line_col .. get_line_col()
    local percentage = colors.percentage .. get_percentage()
    local filetype = colors.filetype .. get_filetype()

    return table.concat({
        colors.active, mode, git, filename,
        '%=% ',
        diagnostics, tagname, line_col, percentage,  filetype
    })
end

vim.cmd [[
set statusline=%!v:lua.Statusline()
]]
