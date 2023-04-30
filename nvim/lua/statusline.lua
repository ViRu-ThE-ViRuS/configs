local core = require('lib/core')
local misc = require('lib/misc')

local tag_state = session.state.tags
local symbols = session.config.symbols
local truncation = session.config.truncation

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
  bufnr       = "%#Pmenu#",
  filetype    = "%#PmenuSel#",
}

-- mode map
local modes = {
  ["n"]  = "Normal",
  ["no"] = "N-Pending",
  ["v"]  = "Visual",
  ["V"]  = "V-Line",
  [""]  = "V-Block",
  ["s"]  = "Select",
  ["S"]  = "S-Line",
  [""]  = "S-Block",
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
  'vista_kind', 'vista', 'fugitive', 'gitcommit', 'fzf', 'NvimTree',
  'DiffviewFiles', 'DiffviewFileHistory', 'dapui_watches', 'dapui_stacks', 'dapui_scopes', 'dapui_breakpoints',
  'dap-repl'
}

-- {{{ utils
-- is statusline supposed to be truncated, will behave according to laststatus
-- setting (global statusline)
--
-- specifying small means we are considering a smaller threshold than normal
-- consider_global means we are to consider with the global statusline (force)
local function truncate_statusline(small, consider_global)
  local limit = (small and truncation.truncation_limit_s) or truncation.truncation_limit
  local global_statusline = vim.api.nvim_get_option_value('laststatus', { scope = 'global' }) == 3
  return misc.is_htruncated(limit, global_statusline or consider_global)
end

-- setup statusline highlights
local function setup_highlights()
  -- want to make all statusline highlights have the same background color
  -- so we don't get any weird looks on colorschemes

  local lsp_icons = require('lsp-setup/lsp_utils').lsp_icons
  local target_id = vim.api.nvim_get_hl_id_by_name(string.sub(colors.context, 3, -2))
  local target_hl = vim.api.nvim_get_hl_by_id(target_id, true)

  for _, value in pairs(lsp_icons) do
    local name = string.sub(value.hl, 3, -2)
    local ts_name = string.sub(name, 5, -1)
    local ts_id = vim.api.nvim_get_hl_id_by_name(ts_name)
    local hl = vim.api.nvim_get_hl_by_id(ts_id, true)

    vim.api.nvim_set_hl(0, name, {
      foreground = hl.foreground,
      background = target_hl.background
    })
  end
end
-- }}}

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

  -- collect information from gitsigns
  meta['branch'] = gitsigns_summary['head']
  meta['added'] = gitsigns_summary['added']
  meta['modified'] = gitsigns_summary['changed']
  meta['removed'] = gitsigns_summary['removed']

  if truncate_statusline() then return string.format(' %s ', meta['branch']) end
  return string.format(
    ' %s | +%s ~%s -%s ',
    meta['branch'],
    meta['added'],
    meta['modified'],
    meta['removed']
  )
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
    -- create tree elements
    local context = core.foreach(tag_state.context[bufnr], function(_, arg)
          return arg.iconhl .. arg.icon .. ' ' .. colors.context .. arg.name
        end) or {}

    local context_tree = table.concat(context, " > ")
    return string.format('[ %s ]', context_tree)
  end
end

-- get current file name
local function get_filename()
  if truncate_statusline(false, true) then return ' %t ' end
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
  if truncate_statusline(true, true) then return '' end
  return ' %n '
end

-- get current file diagnostics
local function get_diagnostics()
  if #vim.lsp.get_active_clients({ bufnr = 0 }) == 0 or truncate_statusline(true) then return '' end

  local status_parts = {}
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  if errors > 0 then
    table.insert(status_parts,
      symbols.indicator_error .. symbols.indicator_seperator .. errors)
  end

  if not truncate_statusline() then
    local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })

    if warnings > 0 then
      table.insert(status_parts,
        symbols.indicator_warning .. symbols.indicator_seperator .. warnings)
    end
    if infos > 0 then
      table.insert(status_parts,
        symbols.indicator_info .. symbols.indicator_seperator .. infos)
    end
    if hints > 0 then
      table.insert(status_parts,
        symbols.indicator_hint .. symbols.indicator_seperator .. hints)
    end
  end

  local status_diagnostics = vim.trim(table.concat(status_parts, ' '))
  if status_diagnostics ~= '' then return ' ' .. status_diagnostics .. ' ' end
  return ''
end
-- }}}

-- {{{ statuslines
-- special statusline with only title
local function statusline_special(title)
  return colors.active .. ' ' .. title .. ' ' .. colors.inactive
end

-- standard active statusline
local function statusline_active()
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
    colors.active, mode, git, diagnostics, truncator, filename, colors.inactive,
    '%=% ',
    context, line_col, percentage, bufnr, filetype, colors.inactive
  })
end

-- standard inactive statusline
local function statusline_inactive()
  local filename = colors.file .. get_filename()
  local line_col = colors.line_col .. get_line_col()
  local bufnr = colors.bufnr .. get_bufnr()
  local filetype = colors.filetype .. get_filetype()

  return table.concat({
    colors.active, filename, colors.inactive,
    '%=% ',
    line_col, bufnr, filetype, colors.inactive
  })
end

-- active statusline
-- convenience function for export
local statusline = function(mode)
  if mode then return statusline_special(mode) end
  return statusline_active()
end
-- }}}

-- {{{ set statusline api
-- get the string value to set on statusline option
-- can be used to set the statusline of another window
local function set_statusline_option(title)
  return "%!luaeval(\"require('statusline').statusline('" .. title .. "')\")"
end

-- get a function which sets statusline option when called
local function set_statusline_func(title, non_local)
  -- NOTE(vir): opt vs opt_local?
  -- some dont work {DiffviewFiles, DiffviewFileHistory} with opt_local
  -- side effects of using global opt?
  if non_local then
    return function() vim.opt.statusline = set_statusline_option(title) end
  else
    return function() vim.opt_local.statusline = set_statusline_option(title) end
  end
end

-- get a [viml]string which can be used to set statusline, eg: using vim.cmd
local function set_statusline_cmd(title)
  -- NOTE(vir): setlocal vs set?
  return 'setlocal statusline=%!luaeval(\'require(\\"statusline\\").statusline(\\"' ..
      vim.fn.escape(title, ' ') .. '\\")\')'
end
-- }}}

-- {{{ statusline setup
local autocmd_group = vim.api.nvim_create_augroup('StatusLine', { clear = true })

-- setup defaults
vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter' }, {
  group = autocmd_group,
  pattern = '*',
  callback = function()
    local ft = vim.api.nvim_get_option_value('ft', { scope = 'local' })
    if not core.table_contains(statusline_blacklist, ft) then
      vim.opt_local.statusline =
        "%!luaeval(\"require('statusline').statusline()\")"
    end
  end
})
vim.api.nvim_create_autocmd({ 'BufLeave', 'WinLeave' }, {
  group = autocmd_group,
  pattern = '*',
  callback = function()
    local ft = vim.api.nvim_get_option_value('ft', { scope = 'local' })
    if not core.table_contains(statusline_blacklist, ft) then
      vim.opt_local.statusline =
        "%!luaeval(\"require('statusline').statusline_inactive()\")"
    end
  end
})

-- setup builtins
vim.api.nvim_create_autocmd('FileType', { group = autocmd_group, pattern = 'terminal', callback = set_statusline_func('Terminal') })
vim.api.nvim_create_autocmd('BufWinEnter', { group = autocmd_group, pattern = 'quickfix', callback = set_statusline_func('QuickFix') })
vim.api.nvim_create_autocmd('BufWinEnter', { group = autocmd_group, pattern = 'diagnostics', callback = set_statusline_func('Diagnostics') })
-- }}}

return {
  setup_highlights = setup_highlights,
  autocmd_group = autocmd_group,              -- augroup for setting statusline

  -- statusline fn
  statusline = statusline,                    -- get current statusline string
  statusline_inactive = statusline_inactive,  -- get inactive statusline string

  -- api to setup statusline
  set_statusline_option = set_statusline_option, -- get the value to set statusline option to (string)
  set_statusline_func = set_statusline_func,     -- calling this function will set the statusline
  set_statusline_cmd = set_statusline_cmd,       -- calling this command will set the statusline
}
