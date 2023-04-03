local utils = require('utils')
local misc = require('lib/misc')
local core = require('lib/core')

local palette = session.state.palette
local truncation = session.config.truncation

-- TODO(vir): future
--   1. terminal palette features
--     - visual reorder
--     - each terminal can have its own base_command, hotkey + fuzzy selector
--   2. general workspace features (bigger than TERM)

-- {{{ utils
-- get index of terminal given terminal_job_id
local function get_terminal_index(job_id)
  assert(job_id, 'terminal_job_id not specified')
  for index, id in pairs(palette.indices) do
    if id == job_id then return index end
  end
end

-- deregister a terminal given job_id
-- this removes it from palette.indices
-- returns true if an entry was deregistered, false if it wasnt needed
local function deregister_terminal(job_id)
  assert(job_id, 'terminal_job_id not specified')
  local index = get_terminal_index(job_id)

  if index then
    -- if deregistering primary, set it to empty
    if index == 1 then
      palette.indices[index] = {}
    else
      table.remove(palette.indices, index)
    end
    return true
  end
end

-- register a terminal given job_id, to the specified index
-- if another valid entry is present at index, it is swapped to the end
-- using a replacement policy documented below
local function register_terminal(job_id, index)
  assert(index >= 0, 'index must be a positive number')
  assert(job_id, 'invalid job_id: ' .. job_id)

  local term_state = palette.terminals[job_id]
  local existing = palette.indices[index]

  local notification = nil

  if existing ~= job_id then
    deregister_terminal(job_id) -- deregister any current index for this terminal

    -- replacing an existing entry
    -- type table represents a removed primary terminal, in which case simply overwrite
    if existing and type(existing) ~= 'table' then
      -- NOTE(vir): basic replacement strategies
      --  1. swap existing to end, if needed
      --  2. swap existing to first empty slot
      --  3. deregister existing because we will overwrite it index slot (term_state will not be altered)

      -- using option 3.
      -- deregister existing entry in slot
      local existing_index = get_terminal_index(existing)
      deregister_terminal(existing)

      utils.notify((existing and type(existing) ~= 'table' and string.format(
          'deregistered terminal <%d>:{ job_id: %s, bufnr: %s }',
          existing_index,
          existing,
          palette.terminals[existing].bufnr
        )) or "", 'warn', { title = '[TERM] palette ', render = 'compact' })
    end

    -- replacement is done, assign index
    palette.indices[index] = job_id

    notification = string.format(
      "terminal set <%d>:{ job_id: %s, bufnr: %s }",
      index,
      term_state.job_id,
      term_state.bufnr
    )
  else
    -- swapping with self
    notification = string.format(
      "terminal already set %s{ job_id: %s, bufnr: %s }",
      string.format('<%d>:', index),
      term_state.job_id,
      term_state.bufnr
    )
  end

  utils.notify(notification, 'info', { title = '[TERM] palette ', render = 'compact' })
end

-- returns true if terminal specified by job_id is a valid target
local function assure_target_valid(job_id)
  assert(job_id, 'terminal_job_id not specified')
  local term_state = palette.terminals[job_id]

  if (not term_state) or (not vim.api.nvim_buf_is_loaded(term_state.bufnr)) then
    deregister_terminal(job_id)
    utils.notify('terminal exitted, resetting index', 'warn', { title = '[TERM] palette ', render = 'compact' })
    return false
  end

  return true
end

-- get term_state of primary terminal if any
local function get_primary_terminal()
  local primary_id = palette.indices[1]
  if not primary_id then return nil end

  local primary_state = palette.terminals[primary_id]
  return primary_state
end
-- }}}

-- {{{ pallet.terminals
-- add/set terminal index
-- if vim.v.count is valid, then index is updated
local function add_terminal(opts)
  opts = vim.tbl_deep_extend('force', {
    primary = false,
    index = nil
  }, opts or {})

  local job_id = vim.b.terminal_job_id
  local index = (opts.primary and 1) or opts.index or vim.v.count -- 0 means no index specified

  -- NOTE(vir): convenience behavior, first terminal we add is primary
  if palette.indices[1] == nil then
    index = 1
  end

  -- only makes sense to call this function from a terminal buffer
  if job_id == nil then
    utils.notify('could not add terminal', 'warn', { title = '[TERM] palette', render = 'compact' })
    return
  end

  -- trying to re-add existing terminal, without specifying index
  -- this is not a reorder request, so we short-circuit
  local existing = palette.terminals[job_id] ~= nil
  if existing and (not index) then
    utils.notify('terminal already added', 'warn', { title = '[TERM] palette ', render = 'compact' })
    return
  end

  -- create new terminal state
  -- old state is always consistent with new state
  local term_state = palette.terminals[job_id] or { job_id = job_id, bufnr = vim.api.nvim_get_current_buf() }
  palette.terminals[job_id] = term_state

  if index ~= 0 then
    -- index is specified, we are swapping instead of adding
    register_terminal(job_id, index)
  else
    -- index is not specified, we are just adding a new terminal, not also
    -- registering it
    local notification = {}

    if existing then
      -- trying to add existing terminal
      index = get_terminal_index(job_id)
      notification.type = 'warn'
      notification.message = string.format(
        "terminal already added %s{ job_id: %s, bufnr: %s }",
        ((index and string.format('<%d>:', index)) or ""),
        term_state.job_id,
        term_state.bufnr
      )
    else
      -- new terminal added
      notification.type = 'info'
      notification.message = string.format(
        "terminal added %s{ job_id: %s, bufnr: %s }",
        ((index ~= 0 and string.format('<%d>:', index)) or ""),
        term_state.job_id,
        term_state.bufnr
      )
    end

    utils.notify(
      notification.message,
      notification.type,
      { title = '[TERM] palette ', render = 'compact' }
    )
  end
end

-- toggle primary/target terminal
-- if count is valid, then it is used as target index
-- otherwise target is primary
local function toggle_terminal(force_open)
  local index = vim.v.count1
  local job_id = palette.indices[index]

  if not job_id then
    utils.notify('index not registered', 'warn', { title = '[TERM] palette ', render = 'compact' })
    return
  end

  if not assure_target_valid(job_id) then return end
  local term_state = palette.terminals[job_id]
  local winid = vim.fn.bufwinid(term_state.bufnr)

  if winid ~= -1 and #vim.api.nvim_list_wins() > 1 then
    -- already open
    if not force_open then vim.api.nvim_win_close(winid, false) end
  else
    -- open in split
    local split_dir = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "") or "v"
    local split_cmd = string.format('%ssplit #%d', split_dir, term_state.bufnr)
    vim.cmd(split_cmd)
  end
end

-- send payload to terminal
-- if count is valid, then it is used as target index
-- otherwise target is primary
--
-- will emulate <up><cr> in terminal if no payload specified
local function send_to_terminal(payload, opts)
  local index = vim.v.count1
  local job_id = palette.indices[index]

  opts = vim.tbl_deep_extend('force', {
    toggle_open = true,  -- toggle open target terminal if not already visible
    scroll_to_end = true -- scroll to end after sending payload
  }, opts or {})

  if not job_id then
    utils.notify('index not registered', 'warn', { title = '[TERM] palette ', render = 'compact' })
    return
  end

  if type(job_id) == 'table' then
    utils.notify('primary terminal exitted', 'warn', { title = '[TERM] palette ', render = 'compact' })
    return
  end

  if not assure_target_valid(job_id) then return end

  -- send to target
  if payload then
    vim.api.nvim_chan_send(job_id, payload .. "\n")
  else
    vim.cmd("call chansend(" .. job_id .. ', "\x1b\x5b\x41\\<cr>")')
  end

  if opts.toggle_open then toggle_terminal(true) end
  if opts.scroll_to_end then misc.scroll_to_end(palette.terminals[job_id].bufnr) end
end

-- send buffer content (visual/line) to terminal
-- if count is valid, then it is used as target index
-- otherwise target is primary
local function send_content_to_terminal(visual_mode)
  local payload = nil

  if visual_mode then
    -- take last visual selection
    local l1 = vim.api.nvim_buf_get_mark(0, "<")[1]
    local l2 = vim.api.nvim_buf_get_mark(0, ">")[1]
    if l1 > l2 then l1, l2 = l2, l1 end

    local lines = vim.api.nvim_buf_get_lines(0, l1 - 1, l2, false)
    payload = table.concat(lines, '\n')
  else
    -- take current line when called from normal mode
    -- it makes sense to trim this before feeding input
    local line = vim.api.nvim_win_get_cursor(0)[1]
    payload = vim.trim(vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1])
  end

  send_to_terminal(payload)
end
-- }}}

-- {{{ palette.commands
-- add to command palette
-- takes input if no command is passed
local function add_command(command)
  -- take input if command param is nil
  command = command or vim.fn.input('command: ', '', 'shellcmd')

  assert(command, 'invalid command: ' .. command)
  assert(not core.table_contains(palette.commands, command), 'adding duplicate command: ' .. command)
  table.insert(palette.commands, command)
end

-- remove command from palette
local function remove_command(command)
  assert(command, 'invalid command: ' .. command)
  local index = core.table_contains(palette.commands, command)

  -- error if trying to remove a command which was not previously added
  assert(index, 'no matching command exists: ' .. command)
  table.remove(palette.commands, index)
end

-- run a command in primary terminal
-- triggers ui selection to pick target
local function run_command()
  vim.ui.select(
    palette.commands,
    { prompt = 'launch command> ' },
    function(command) send_to_terminal(command) end
  )
end
-- }}}

-- launch new terminal
local function launch_terminal(command, opts)
  assert(command and command ~= '', "invalid shell command: " .. command)

  opts = vim.tbl_deep_extend('force', {
    background = false,
    callback = nil,
    bufname = command
  }, opts or {})

  -- create new terminal
  local split_cmd = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "sp") or "vsp"
  vim.cmd(string.format('%s | terminal', split_cmd))

  -- TODO(vir): investigate why this is necessary
  vim.api.nvim_exec_autocmds('TermOpen', { group = 'TerminalSetup' })

  -- terminal state
  local term_state = {
    bufnr = vim.api.nvim_get_current_buf(),
    job_id = vim.b.terminal_job_id,
    bufname = opts.bufname
  }

  -- try setting name, fails if buffer with same name exists
  pcall(vim.api.nvim_buf_set_name, term_state.bufnr, term_state.bufname)

  -- this should not crash, so pcall not needed
  vim.api.nvim_chan_send(term_state.job_id, command .. "\n")
  utils.notify(command, 'info', { title = '[TERM] launched command' })

  -- wrap up
  if opts.callback then opts.callback() end
  if opts.background then vim.api.nvim_win_close(vim.fn.bufwinid(term_state.bufnr), true)
  else vim.cmd [[ wincmd p ]] end

  return term_state
end

return {
  -- terminals
  add_terminal = add_terminal,
  toggle_terminal = toggle_terminal,
  send_to_terminal = send_to_terminal,
  send_content_to_terminal = send_content_to_terminal,

  -- commands
  add_command = add_command,
  remove_command = remove_command,
  run_command = run_command,

  -- misc
  launch_terminal = launch_terminal,
  get_primary_terminal = get_primary_terminal
}
