local proto = require('vim.lsp.protocol')
local core = require('lib/core')
local misc = require('lib/misc')

local tag_state = session.state.tags
local diagnostics_state = session.state.ui.diagnostics_state
local truncation = session.config.truncation

-- {{{ config variables
-- tag states for statusline
local tag_state_filter = {
  Class     = true,
  Function  = true,
  Method    = true,
  Struct    = true,
  Enum      = true,
  Interface = true,
  Namespace = true,
  Module    = true,
}

-- lsp str(kind) -> icon(kind)
local lsp_icons = {
  File          = { icon = "", hl = "%#SLTSURI#" },
  Module        = { icon = "", hl = "%#SLTSNamespace#" },
  Namespace     = { icon = "", hl = "%#SLTSNamespace#" },
  Package       = { icon = "", hl = "%#SLTSNamespace#" },
  Class         = { icon = "𝓒", hl = "%#SLTSType#" },
  Method        = { icon = "ƒ", hl = "%#SLTSMethod#" },
  Property      = { icon = "", hl = "%#SLTSMethod#" },
  Field         = { icon = "", hl = "%#SLTSField#" },
  Constructor   = { icon = "", hl = "%#SLTSConstructor#" },
  Enum          = { icon = "ℰ", hl = "%#SLTSType#" },
  Interface     = { icon = "ﰮ", hl = "%#SLTSType#" },
  Function      = { icon = "", hl = "%#SLTSFunction#" },
  Variable      = { icon = "", hl = "%#SLTSConstant#" },
  Constant      = { icon = "", hl = "%#SLTSConstant#" },
  String        = { icon = "𝓐", hl = "%#SLTSString#" },
  Number        = { icon = "#", hl = "%#SLTSNumber#" },
  Boolean       = { icon = "⊨", hl = "%#SLTSBoolean#" },
  Array         = { icon = "", hl = "%#SLTSConstant#" },
  Object        = { icon = "⦿", hl = "%#SLTSType#" },
  Key           = { icon = "🔐", hl = "%#SLTSType#" },
  Null          = { icon = "NULL", hl = "%#SLTSType#" },
  EnumMember    = { icon = "", hl = "%#SLTSField#" },
  Struct        = { icon = "𝓢", hl = "%#SLTSType#" },
  Event         = { icon = "🗲", hl = "%#SLTSType#" },
  Operator      = { icon = "+", hl = "%#SLTSOperator#" },
  TypeParameter = { icon = "𝙏", hl = "%#SLTSParameter#" }
}

-- debug_print config
local debug_print_config = {
  postfix = '__DEBUG_PRINT__',

  -- NOTE(vir): format string with 2 strings (%s) [label, target]
  --            support more languages as needed
  fmt     = {
    lua    = 'print("%s: ", vim.inspect(%s))',
    c      = 'printf("%s: %%s", %s);',
    cpp    = 'std::cout << "%s: " << %s << std::endl;',
    python = 'print(f"%s: {str(%s)}")',
  },
}
-- }}}

-- {{{ utils
-- pos in range
local function in_range(pos, range)
  if pos[1] < range['start'].line or pos[1] > range['end'].line then
    return false
  end

  if (pos[1] == range['start'].line and pos[2] < range['start'].character) or
      (pos[1] == range['end'].line and pos[2] > range['end'].character) then
    return false
  end

  return true
end


-- extract symbols from lsp results
local function extract_symbols(items, result)
  result = result or {}
  if items == nil then return result end

  for _, item in ipairs(items) do
    local kind = proto.SymbolKind[item.kind] or 'Unknown'
    local symbol_range = item.range or item.location.range

    if symbol_range then
      symbol_range['start'].line = symbol_range['start'].line + 1
      symbol_range['end'].line = symbol_range['end'].line + 1
    end

    table.insert(result, {
      filename = (item.location and vim.uri_to_fname(item.location.uri)) or nil,
      range = symbol_range,
      kind = kind,
      name = item.name,
      detail = item.detail,
      raw = item
    })

    extract_symbols(item.children, result)
  end

  return result
end
-- }}}

-- {{{ tag_state api
-- clear buffer tags and context cache
local function clear_buffer_tags(bufnr)
  -- equivalent to removing buffer entry from cache to end tracking
  tag_state.context[bufnr] = nil
  tag_state.cache[bufnr] = nil
  tag_state.req_state[bufnr] = nil
end

-- calculate and update context at current location using latest cache
local function update_context()
  local bufnr = vim.api.nvim_get_current_buf()
  local symbols = tag_state.cache[bufnr]
  if not symbols or vim.tbl_isempty(symbols) then return end

  local hovered_line = vim.api.nvim_win_get_cursor(0)
  local contexts = {}

  -- go through all symbols in this buffer
  for index = #symbols, 1, -1 do
    local current = symbols[index]

    if current.range and in_range(hovered_line, current.range) then
      table.insert(contexts, {
        kind = current.kind,
        name = current.name,
        detail = current.detail,
        range = current.range,
        icon = lsp_icons[current.kind].icon,
        iconhl = lsp_icons[current.kind].hl
      })
    end
  end

  if not vim.tbl_isempty(contexts) then
    -- sort based on ascending tag end locations
    table.sort(contexts, function(a, b)
      return (a.range['end'].line > b.range['end'].line) or
          (b.range['end'].character > b.range['end'].character)
    end)

    tag_state.context[bufnr] = contexts
    return
  end

  -- no context found
  tag_state.context[bufnr] = nil
end

-- update tag_state for current buffer
-- setup on lsp load: CursorHold triggers refreshing of tag cache for buffer
local function update_tags()
  local bufnr = vim.api.nvim_get_current_buf()

  -- set defaults for a new buffer
  tag_state.req_state[bufnr] = tag_state.req_state[bufnr] or {
    waiting = false, -- lsp request results are awaited
    last_tick = 0,   -- last time tags were refreshed
  }

  -- we only continue if we are not waiting and were last updated in the past
  if not (not tag_state.req_state[bufnr].waiting and
      tag_state.req_state[bufnr].last_tick < vim.b.changedtick) then
    return
  end

  -- update tags
  tag_state.req_state[bufnr] = { waiting = true, last_tick = vim.b.changedtick }
  vim.lsp.buf_request(
    bufnr,
    'textDocument/documentSymbol',
    { textDocument = vim.lsp.util.make_text_document_params() },
    function(_, results, _, _)
      -- buffer might have closed by the time this request completed
      if not tag_state.req_state[bufnr] then return end

      -- results have arrived
      tag_state.req_state[bufnr].waiting = false

      -- exit if buffer is invalid or if no results were returned
      if not vim.api.nvim_buf_is_valid(bufnr) then return end
      if (not results) or (type(results) ~= 'table') then return end

      -- extract and filter symbols
      -- keep only those of types in context lists
      local symbols = core.filter(
        extract_symbols(results),
        function(_, value) return tag_state_filter[value.kind] end
      )

      if not symbols or vim.tbl_isempty(symbols) then return end
      tag_state.cache[bufnr] = symbols
    end
  )
end
-- }}}

-- get current context with formatting
-- format_fn(context) can format as context needed
local function get_context(bufnr, format_fn)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  format_fn = format_fn or (function(context) return context end)

  if tag_state.context[bufnr] == nil then return format_fn({}) end
  return format_fn(tag_state.context[bufnr])
end

-- get current context winbar string
local function get_context_winbar(bufnr, colors)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  -- same as context colors in statusline
  colors = colors or {
    foreground = "%#WinBar#",
    background = "%#WinBar#",
  }

  local filename = (misc.is_htruncated(truncation.truncation_limit, true) and ' [ %t ] ') or ' [ %f ] '
  local context = get_context(bufnr, function(context_tbl)
    -- format for the winbar
    local context = core.foreach(
          context_tbl,
          function(_, arg)
            return arg.iconhl .. arg.icon .. ' ' .. colors.background .. arg.name
          end
        ) or {}

    return table.concat(context, " -> ")
  end)

  -- context = (string.len(context) > 1 and '=> ' .. context) or context
  -- return colors.foreground .. filename .. colors.background .. context

  local left = string.format('%s => %s', colors.foreground, context)
  local right = (string.len(left) <= core.round(vim.api.nvim_win_get_width(0) * 0.80)
      and filename) or ""

  return left .. '%=%' .. right
end

-- toggle global(workspace) / local(buffer) diagnostics qflist
-- powered by diagnostics api, does not depend on lsp directly
local function toggle_diagnostics_list(global)
  if global then
    if not diagnostics_state['global'] then
      if #vim.diagnostic.get(nil) > 0 then
        vim.diagnostic.setqflist()
        diagnostics_state['global'] = true

        require('statusline').set_statusline_func('Workspace Diagnostics')()
        vim.cmd [[ wincmd p ]]
      end
    else
      diagnostics_state['global'] = false
      vim.cmd [[ cclose ]]
    end
  else
    local current_buf = vim.api.nvim_get_current_buf()

    if not diagnostics_state['local'][current_buf] then
      if #vim.diagnostic.get(0) > 0 then
        vim.diagnostic.setloclist()
        diagnostics_state['local'][current_buf] = true

        require('statusline').set_statusline_func('Diagnostics')()
        vim.cmd [[ wincmd p ]]
      end
    else
      diagnostics_state['local'][current_buf] = false
      vim.cmd [[ lclose ]]
    end
  end
end

-- toggle debug print statement for current selection / tresitter node
-- powered by treesitter, does not depend on lsp
local function debug_print(visual)
  local target_line = nil
  local target = nil

  -- NOTE(vir): no error handling, to remind me that i need to add missing config
  local ft = vim.api.nvim_get_option_value('filetype', { scope = 'local' })
  local template = debug_print_config.fmt[ft]
  local postfix_raw = debug_print_config.postfix
  local postfix = ' ' .. vim.api.nvim_get_option_value('commentstring', { scope = 'local' })
    :format(postfix_raw)

  if visual then
    local selection_start = vim.api.nvim_buf_get_mark(0, "<")
    local selection_end = vim.api.nvim_buf_get_mark(0, ">")

    local start_line = selection_start[1]
    local end_line = selection_end[1]
    local start_col = selection_start[2]
    local end_col = selection_end[2]

    -- only support single line selections
    if start_line ~= end_line then return end
    if end_col - start_col > 100 then return end

    target_line = start_line - 1
    target = vim.trim(vim.api.nvim_buf_get_text(0, start_line - 1, start_col, start_line - 1, end_col + 1, {})[1])
  else
    local current = vim.treesitter.get_node()
    local start_line, _, end_line, _, _ = vim.treesitter.get_node_range(current)

    -- only support single line nodes
    if start_line ~= end_line then return end

    target_line = start_line
    target = vim.treesitter.get_node_text(current, 0)
  end

  -- debug print statement to insert
  local debug_print_statement = template:format(target, target) .. postfix

  -- toggle print if already present
  local current_line = vim.api.nvim_buf_get_lines(0, target_line, target_line + 1, true)[1]
  local next_line = vim.api.nvim_buf_get_lines(0, target_line + 1, target_line + 2, false)[1]
  if current_line and current_line:find(postfix_raw) then
    vim.api.nvim_buf_set_lines(0, target_line, target_line + 1, true, {})
    return
  end
  if next_line and vim.trim(next_line) == debug_print_statement then
    vim.api.nvim_buf_set_lines(0, target_line + 1, target_line + 2, true, {})
    return
  end

  -- insert statement
  vim.api.nvim_buf_set_lines(0, target_line + 1, target_line + 1, false, { debug_print_statement })

  -- indent statement
  vim.cmd [[ normal! =jh ]]

  -- format using lsp
  -- vim.lsp.buf.format({ bufnr = 0, async = true, range = {
  --     ['start'] = { target_line + 2, 0 },
  --     ['end'] = { target_line + 2, #debug_print_statement },
  -- } })
end

return {
  lsp_icons               = lsp_icons,

  -- misc
  get_context             = get_context,
  get_context_winbar      = get_context_winbar,
  toggle_diagnostics_list = toggle_diagnostics_list,
  debug_print             = debug_print,

  -- context tag_state api
  update_tags             = update_tags,
  update_context          = update_context,
  clear_buffer_tags       = clear_buffer_tags,
}
