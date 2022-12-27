local utils = require('utils')
local core = require('lib/core')

local tag_state = utils.editor_config.tag_state
local symbol_config = utils.editor_config.symbol_config
local truncation = utils.editor_config.truncation

-- statusline colors
local colors = {
    active      = "%#StatusLine#",
    inactive    = "%#StatusLineNC#",
    mode        = "%#PmenuSel#",
    git         = "%#Pmenu#",
    diagnostics = "%#PmenuSbar#",
    file        = "%#CursorLine#",
    context     = "%#WinBar#",
    line_col    = "%#CursorLine#",
    percentage  = "%#CursorLine#",
    bufnr       = "%#PmenuSbar#",
    filetype    = "%#PmenuSel#",
}

-- mode map
local modes = {
    ["n"]  = "Normal",
    ["no"] = "N-Pending",
    ["v"]  = "Visual",
    ["V"]  = "V-Line",
    [""] = "V-Block",
    ["s"]  = "Select",
    ["S"]  = "S-Line",
    [""] = "S-Block",
    ["i"]  = "Insert",
    ["ic"] = "Insert",
    ["R"]  = "Replace",
    ["Rv"] = "V-Replace",
    ["c"]  = "Command",
    ["cv"] = "Vim-Ex ",
    ["ce"] = "Ex",
    ["r"]  = "Prompt",
    ["rm"] = "More",
    ["r?"] = "Confirm",
    ["!"]  = "Shell",
    ["t"]  = "Terminal",
}

-- do not set default behavior on thesefile types
local statusline_blacklist = {
    'terminal', 'diagnostics', 'qf',
    'vista_kind', 'vista', 'fugitive', 'gitcommit','fzf', 'NvimTree',
    'DiffviewFiles', 'DiffviewFileHistory', 'dapui_watches', 'dapui_stacks', 'dapui_scopes', 'dapui_breakpoints', 'dap-repl'
}

-- is statusline supposed to be truncated
local function truncate_statusline(small)
    local limit = (small and truncation.truncation_limit_s) or truncation.truncation_limit
    local get_global = vim.api.nvim_get_option_value('laststatus', { scope = 'global' }) == 3
    return utils.is_htruncated(limit, get_global)
end

-- {{{ providers
-- get the display name for current mode
local function get_current_mode()
    local current_mode = vim.api.nvim_get_mode().mode
    return string.format(' %s ', modes[current_mode]):upper()
end

-- NOTE(vir): release gitsigns dependencies?
-- get git information of current file
local function get_git_status()
    local meta = {}
    local gitsigns_summary = vim.b.gitsigns_status_dict
    if not gitsigns_summary then return '' end

    meta['branch'] = gitsigns_summary['head']
    meta['added'] = gitsigns_summary['added']
    meta['modified'] = gitsigns_summary['changed']
    meta['removed'] = gitsigns_summary['removed']

    if truncate_statusline() then return string.format(' %s ', meta['branch']) end
    return string.format(' %s | +%s ~%s -%s ', meta['branch'], meta['added'], meta['modified'], meta['removed'])
end

-- get current context / tag
local function get_statusline_context(bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if tag_state.context[bufnr] == nil or truncate_statusline(true) then return '' end

    if truncate_statusline(true) then
        local context = tag_state.context[bufnr]
        return string.format(
            "[ %s%s %s%s ] ",
            context[#context].iconhl,
            context[#context].icon,
            context[#context].colors.context,
            context[#context].name
        )
    else
        local context = core.foreach(tag_state.context[bufnr], function(arg)
            return arg.iconhl .. arg.icon .. ' ' .. colors.context .. arg.name
        end) or {}

        local context_tree = table.concat(context, " > ")
        return string.format('[ %s ]', context_tree)
    end
end

-- get current file name
local function get_filename()
    if truncate_statusline() then return ' %t ' end
    return ' %f '
end

-- get current line/col
local function get_line_col() return ' %l:%c ' end

-- get current percentage through file
local function get_percentage()
    if truncate_statusline() then return '' end
    return ' %p%% '
end

-- get current file type
local function get_filetype() return ' %y ' end

-- get buffer number
local function get_bufnr()
    if truncate_statusline(true) then return '' end
    return ' %n '
end

-- get current file diagnostics
local function get_diagnostics()
    if #vim.lsp.get_active_clients({bufnr=0}) == 0 or truncate_statusline(true) then return '' end

    local status_parts = {}
    local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    if errors > 0 then table.insert(status_parts, symbol_config.indicator_error .. symbol_config.indicator_seperator .. errors) end

    if not truncate_statusline() then
        local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
        local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
        local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })

        if warnings > 0 then table.insert(status_parts, symbol_config.indicator_warning .. symbol_config.indicator_seperator .. warnings) end
        if infos > 0 then table.insert(status_parts, symbol_config.indicator_info .. symbol_config.indicator_seperator .. infos) end
        if hints > 0 then table.insert(status_parts, symbol_config.indicator_hint .. symbol_config.indicator_seperator .. hints) end
    end

    local status_diagnostics = vim.trim(table.concat(status_parts, ' '))
    if status_diagnostics ~= '' then return ' ' .. status_diagnostics .. ' ' end
    return ''
end
-- }}}

-- {{{ statuslines
-- special statusline
local function statusline_special(mode)
    return colors.active .. ' ' .. mode .. ' ' .. colors.inactive
end

-- normal statusline
local function statusline_normal()
    local mode = colors.mode .. get_current_mode()
    local git = colors.git .. get_git_status()
    local diagnostics = colors.diagnostics .. get_diagnostics()
    local truncator = '%<'
    local filename = colors.file .. get_filename()
    local context = colors.context .. get_statusline_context()
    local line_col = colors.line_col .. get_line_col()
    local percentage = colors.percentage .. get_percentage()
    local bufnr = colors.bufnr .. get_bufnr()
    local filetype = colors.filetype .. get_filetype()

    return table.concat({
        colors.active, mode, git, diagnostics, truncator, filename,
        colors.inactive, '%=% ', context, line_col, percentage, bufnr, filetype,
        colors.inactive
    })
end

-- active statusline
local statusline = function(mode)
    if mode then return statusline_special(mode) end
    return statusline_normal()
end

-- inactive statusline
local function statusline_inactive()
    local filename = colors.file .. ' %t '
    local line_col = colors.line_col .. ' %l:%c '
    local bufnr = colors.bufnr .. ' %n '
    local filetype = colors.filetype .. ' %y '

    return table.concat({
        colors.active, filename, colors.inactive,
        '%=% ',
        line_col, bufnr, filetype, colors.inactive
    })
end
-- }}}

-- {{{ set statusline api
-- get a function which sets statusline option when called
local function set_statusline_func(title, non_local)
    -- NOTE(vir): opt vs opt_local?
    -- some dont work {DiffviewFiles, DiffviewFileHistory} with opt_local
    -- side effects of using global opt?
    if non_local then return function() vim.opt.statusline =  "%!luaeval(\"require('statusline').statusline('" .. title .. "')\")" end
    else return function() vim.opt_local.statusline =  "%!luaeval(\"require('statusline').statusline('" .. title .. "')\")" end end
end

-- get a string which can be used to set statusline in vimscript
local function set_statusline_cmd(title)
    -- NOTE(vir): setlocal vs set?
    return 'setlocal statusline=%!luaeval(\'require(\\"statusline\\").statusline(\\"' .. vim.fn.escape(title, ' ') .. '\\")\')'
end
-- }}}

-- {{{ statusline setup
-- setup defaults
vim.api.nvim_create_augroup('StatusLine', {clear = true})
vim.api.nvim_create_autocmd({'BufEnter', 'WinEnter'}, {group='StatusLine', pattern='*', callback = function()
    local ft = vim.api.nvim_get_option_value('ft', {scope = 'local'})
    if not core.table_contains(statusline_blacklist, ft) then vim.opt_local.statusline = "%!luaeval(\"require('statusline').statusline()\")" end
end})
vim.api.nvim_create_autocmd({'BufLeave', 'WinLeave'}, {group='StatusLine', pattern='*', callback = function()
    local ft = vim.api.nvim_get_option_value('ft', {scope = 'local'})
    if not core.table_contains(statusline_blacklist, ft) then vim.opt_local.statusline = "%!luaeval(\"require('statusline').statusline_inactive()\")" end
end})

-- setup builtins
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='terminal', callback = set_statusline_func('Terminal')})
vim.api.nvim_create_autocmd('BufWinEnter', {group='StatusLine', pattern='quickfix', callback = set_statusline_func('QuickFix')})
vim.api.nvim_create_autocmd('BufWinEnter', {group='StatusLine', pattern='diagnostics', callback = set_statusline_func('Diagnostics')})

-- setup plugins
vim.api.nvim_create_autocmd('BufWinEnter', {group='StatusLine', pattern='NvimTree_1', callback = set_statusline_func('Explorer')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='fzf', callback = set_statusline_func('FZF')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern={'vista_kind', 'vista'}, callback = set_statusline_func('Outline')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern={'fugitive', 'git'}, callback = set_statusline_func('Git')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='gitcommit', callback = set_statusline_func('GitCommit')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='DiffviewFiles', callback = set_statusline_func('DiffViewFiles', true)})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='DiffviewFileHistory', callback = set_statusline_func('DiffViewFileHistory', true)})

vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='dapui_watches', callback=set_statusline_func('Watches')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='dapui_stacks', callback=set_statusline_func('Stacks')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='dapui_scopes', callback=set_statusline_func('Scopes')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='dapui_breakpoints', callback=set_statusline_func('Breaks')})
vim.api.nvim_create_autocmd('FileType', {group='StatusLine', pattern='dap-repl', callback=set_statusline_func('Repl')})
-- }}}

return {
    statusline = statusline,
    statusline_inactive = statusline_inactive,
    statusline_colors = colors,

    set_statusline_func = set_statusline_func,
    set_statusline_cmd = set_statusline_cmd,
}
