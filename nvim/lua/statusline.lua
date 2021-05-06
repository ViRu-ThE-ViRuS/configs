local utils = require('utils')
local symbol_config = utils.symbol_config
local truncation_limit = utils.truncation_limit

-- color config
local colors = {
    active      = '%#StatusLine#',
    inactive    = '%#StatusLineNC#',
    mode        = '%#PmenuSel#',
    git         = '%#Pmenu#',
    file        = '%#CursorLine#',
    diagnostics = '%#PmenuSel#',
    tagname     = '%#Pmenu#',
    line_col    = '%#CursorLine#',
    percentage  = '%#CursorLine#',
    filetype    = '%#Pmenu#',
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

-- is buffer truncated
local is_truncated = function(width)
  local current_width = vim.api.nvim_win_get_width(0)
  return current_width < width
end

-- get the display name for current mode
local get_current_mode = function()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format(' %s ', modes[current_mode]):upper()
end

-- TODO(vir): release fugitive and gitgutter dependencies
-- get git information of current file
local get_git_status = function()
    local meta = {}
    meta['branch'] = vim.fn['fugitive#head']()

    local git_summary = vim.fn['GitGutterGetHunkSummary']()
    meta['added'] = git_summary[1]
    meta['modified'] = git_summary[2]
    meta['removed'] = git_summary[3]

    if meta['branch'] == '' then
        return ''
    elseif is_truncated(truncation_limit) then
        return string.format(' %s ', meta['branch'])
    else
        return string.format(' %s | +%s ~%s -%s ', meta['branch'], meta['added'], meta['modified'], meta['removed'])
    end
end

-- TODO(vir): release tagbar dependency
-- get current tag name
local get_tagname = function()
    if is_truncated(truncation_limit) then return '' end
    return vim.fn['tagbar#currenttag'](' [%s] ', '')
end

-- get current file name
local get_filename = function()
    return ' %<%f '
end

-- get current line/col
local get_line_col = function()
    return ' %l:%c '
end

-- get current percentage through file
local get_percentage = function()
    if is_truncated(truncation_limit) then
        return ''
    else
        return ' %p%% '
    end
end

-- get current file type
local get_filetype = function()
    return ' %y '
end

-- get current file diagnostics
local get_diagnostics = function()
    if #vim.lsp.buf_get_clients(0) == 0 then return '' end

    local status_parts = {}
    local errors = vim.lsp.diagnostic.get_count(0, 'Error')

    if errors > 0 then
        table.insert(status_parts, symbol_config.indicator_error .. symbol_config.indicator_seperator .. errors)
    end

    if not is_truncated(truncation_limit) then
        local warnings = vim.lsp.diagnostic.get_count(0, 'Warning')
        local hints = vim.lsp.diagnostic.get_count(0, 'Hint')
        local infos = vim.lsp.diagnostic.get_count(0, 'Info')

        if warnings > 0 then
            table.insert(status_parts, symbol_config.indicator_warning .. symbol_config.indicator_seperator .. warnings)
        end

        if infos > 0 then
            table.insert(status_parts, symbol_config.indicator_info .. symbol_config.indicator_seperator .. infos)
        end

        if hints > 0 then
            table.insert(status_parts, symbol_config.indicator_hint .. symbol_config.indicator_seperator .. hints)
        end
    end

    local status_diagnostics = vim.trim(table.concat(status_parts, ' '))
    if status_diagnostics ~= '' then return ' ' .. status_diagnostics .. ' ' end
    return ''
end

-- active statusline
local statusline_active = function()
    local mode = colors.mode .. get_current_mode()
    local git = colors.git .. get_git_status()
    local filename = colors.file .. get_filename()
    local diagnostics = colors.diagnostics .. get_diagnostics()
    local tagname = colors.tagname .. get_tagname()
    local line_col = colors.line_col .. get_line_col()
    local percentage = colors.percentage .. get_percentage()
    local filetype = colors.filetype .. get_filetype()

    return table.concat({
        colors.active, mode, git, diagnostics, filename, colors.inactive,
        '%=% ',
        tagname, line_col, percentage,  filetype, colors.inactive
    })
end

-- special statusline
local statusline_special = function(mode)
    return colors.active .. ' ' .. mode .. ' ' .. colors.inactive
end

-- generate statusline
StatusLine = function(mode)
    if mode == 'explorer' then
        return statusline_special('Explorer')
    elseif mode == 'quick_fix' then
        return statusline_special('QuickFix')
    else
        return statusline_active()
    end
end

vim.cmd [[
set statusline=%!v:lua.StatusLine()

augroup Statusline
    autocmd!
    autocmd WinEnter,BufEnter,FileType NvimTree setlocal statusline=%!v:lua.StatusLine('explorer')
    autocmd WinEnter,BufEnter,FileType qf setlocal statusline=%!v:lua.StatusLine('quick_fix')
augroup end
]]

vim.g.tagbar_status_func = 'CleanTagbarStatus'
vim.cmd [[
function! CleanTagbarStatus(current, sort, fname, flags) abort
    return '%#StatusLine# Tagbar %#StatusLineNC#'
endfunction
]]
