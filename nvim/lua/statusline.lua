local utils = require('utils')
local symbol_config = utils.symbol_config
local truncation_limit = utils.truncation_limit
local colors = utils.statusline_colors

-- get the display name for current mode
local get_current_mode = function()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format(' %s ', utils.modes[current_mode]):upper()
end

-- NOTE(vir): release gitsigns dependencies?
-- get git information of current file
local get_git_status = function()
    local meta = {}
    local gitsigns_summary = vim.b.gitsigns_status_dict

    if not gitsigns_summary then
        return ''
    end

    meta['branch'] = gitsigns_summary['head']
    meta['added'] = gitsigns_summary['added']
    meta['modified'] = gitsigns_summary['changed']
    meta['removed'] = gitsigns_summary['removed']

    if utils.is_htruncated(truncation_limit) then
        return string.format(' %s ', meta['branch'])
    else
        return string.format(' %s | +%s ~%s -%s ', meta['branch'], meta['added'], meta['modified'], meta['removed'])
    end
end

-- get current tag name
local get_tagname = function()
    if utils.tag_state.name == nil or
       utils.is_htruncated(utils.truncation_limit_s) or
       #vim.lsp.buf_get_clients(0) == 0 then
        return ''
    else
        return string.format(" [ %s %s ] ", utils.tag_state.icon, utils.tag_state.name)
    end
end

-- get current file name
local get_filename = function()
    if utils.is_htruncated(truncation_limit) then
        return ' %t '
    end

    return ' %f '
end

-- get current line/col
local get_line_col = function()
    return ' %l:%c '
end

-- get current percentage through file
local get_percentage = function()
    if utils.is_htruncated(truncation_limit) then
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
    local errors = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.ERROR})

    if errors > 0 then
        table.insert(status_parts, symbol_config.indicator_error .. symbol_config.indicator_seperator .. errors)
    end

    if not utils.is_htruncated(truncation_limit) then
        local warnings = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.WARN})
        local hints = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.HINT})
        local infos = #vim.diagnostic.get(0, {severity = vim.diagnostic.severity.INFO})

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

-- special statusline
local statusline_special = function(mode)
    return colors.active .. ' ' .. mode .. ' ' .. colors.inactive
end

-- inactive statusline
local statusline_inactive = function()
    local filename = colors.file .. get_filename()
    local line_col = colors.line_col .. get_line_col()
    local percentage = colors.percentage .. get_percentage()
    local filetype = colors.filetype .. get_filetype()

    return table.concat({
        colors.active, filename, colors.inactive,
        '%=% ',
        line_col, percentage, filetype, colors.inactive
    })
end

-- active statusline
local statusline_normal = function()
    local mode = colors.mode .. get_current_mode()
    local git = colors.git .. get_git_status()
    local diagnostics = colors.diagnostics .. get_diagnostics()
    local truncator = '%<'
    local filename = colors.file .. get_filename()
    local tagname = colors.tagname .. get_tagname()
    local line_col = colors.line_col .. get_line_col()
    local percentage = colors.percentage .. get_percentage()
    local filetype = colors.filetype .. get_filetype()

    return table.concat({
        colors.active, mode, git, diagnostics, truncator, filename, colors.inactive,
        '%=% ',
        tagname, line_col, percentage,  filetype, colors.inactive
    })
end

-- module
M = {}

-- generate statusline
StatusLine = function(mode)
    if mode then
        return statusline_special(mode)
    else
        return statusline_normal()
    end
end
M.StatusLine = StatusLine

-- generate inactive statusline
StatusLineInactive = function()
    return statusline_inactive()
end
M.StatusLineInactive = StatusLineInactive

vim.cmd [[
    let statusline_blacklist = ['terminal', 'vista', 'diagnostics', 'qf']

    augroup StatusLine
        autocmd!
        autocmd WinEnter,BufEnter * if index(statusline_blacklist, &ft) < 0 | setlocal statusline=%!v:lua.StatusLine()
        autocmd WinLeave,BufLeave * if index(statusline_blacklist, &ft) < 0 | setlocal statusline=%!v:lua.StatusLineInactive()

        autocmd WinEnter,BufEnter,WinLeave,BufLeave,FileType terminal setlocal statusline=%!v:lua.StatusLine('Terminal')
        autocmd WinEnter,BufEnter,WinLeave,BufLeave,FileType NvimTree setlocal statusline=%!v:lua.StatusLine('Explorer')
        autocmd WinEnter,BufEnter,WinLeave,BufLeave,FileType vista setlocal statusline=%!v:lua.StatusLine('VISTA')
        autocmd WinEnter,BufEnter,WinLeave,BufLeave,FileType qf setlocal statusline=%!v:lua.StatusLine('QuickFix')
        autocmd WinEnter,BufEnter,WinLeave,BufLeave,FileType diagnostics setlocal statusline=%!v:lua.StatusLine('Diagnostics')
    augroup end
]]

return M
