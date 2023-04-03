local utils = require('utils')
local misc = require('lib/misc')

local run_config = session.state.run_config
local truncation = session.config.truncation

-- returns if run_config.target_terminal is valid
local function assure_target_valid()
  -- not configured
  if not run_config.target_terminal then
    utils.notify('not set', 'warn', { title = '[TERM] target', render = 'compact' })
    return false
  end

  -- not valid
  if not vim.api.nvim_buf_is_loaded(run_config.target_terminal.bufnr) then
    utils.notify('exited, resetting state', 'debug', { title = '[TERM] target', render = 'compact' })
    run_config.target_terminal = nil
    return false
  end

  return true
end

-- set target_terminal/target_command
local function set_target(command)
  if vim.b.terminal_job_id ~= nil then
    assert(not command, "command ~= nil doesn't mabe sense when called from terminal buffer")

    -- override existing setup
    run_config.target_terminal = {
      bufnr = vim.api.nvim_get_current_buf(),
      job_id = vim.b.terminal_job_id,
    }

    utils.notify(
      string.format(
        "set to: { job_id: %s, bufnr: %s }",
        run_config.target_terminal.job_id,
        run_config.target_terminal.bufnr
      ),
      "info",
      { title = '[TERM] target', render = "compact" }
    )
  else
    run_config.target_command = command or vim.fn.input('[TERM] target command: ', '', 'shellcmd')

    utils.notify(
      string.format("set to: %s", run_config.target_command),
      "info",
      { title = '[TERM] command', render = "compact" }
    )
  end
end

-- toggle target_terminal
local function toggle_target(force_open)
  if not assure_target_valid() then return end

  -- toggle if needed
  local target_winid = vim.fn.bufwinid(run_config.target_terminal.bufnr)
  if target_winid ~= -1 and #vim.api.nvim_list_wins() > 1 then
    -- already open
    if not force_open then vim.api.nvim_win_close(target_winid, false) end
  else
    -- open in split
    local split_dir = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "") or "v"
    local split_cmd = string.format('%ssplit #%d', split_dir, run_config.target_terminal.bufnr)
    vim.cmd(split_cmd)
  end
end

-- send payload to target_terminal
local function send_to_target(payload, repeat_last)
  if not assure_target_valid() then return end

  -- send command
  if repeat_last then
    assert(not payload, 'payload specified, along with repeat_last')
    vim.cmd("call chansend(" .. run_config.target_terminal.job_id .. ', "\x1b\x5b\x41\\<cr>")')
  else
    vim.api.nvim_chan_send(run_config.target_terminal.job_id, payload .. "\n")
  end

  -- open target terminal and scroll to bottom
  toggle_target(true)
  misc.scroll_to_end(run_config.target_terminal.bufnr)
end

-- send lines to target_terminal
local function send_content_to_target(visual_mode)
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

  send_to_target(payload)
end

-- run target_command
local function run_target_command()
  if not run_config.target_command then
    utils.notify('command not set', 'warn', { title = '[TERM] command', render = 'compact' })
    return
  end

  send_to_target(run_config.target_command, false)
end

-- run previous command in target_terminal
local function run_previous_command()
  send_to_target(nil, true)
end

-- add configuration to palette
local function add_to_palette(command)
  assert(command, 'invalid command: ' .. command)
  table.insert(run_config.palette, command)
end

-- trigger selection from palette
local function run_from_palette()
  vim.ui.select(
    run_config.palette,
    { prompt = 'launch command> ' },
    function(command) send_to_target(command) end
  )
end

-- launch a terminal with the command in a split
local function launch_terminal(command, opts)
  assert(command, "invalid shell command: " .. command)
  opts = vim.tbl_deep_extend('force', {
    background = false,
    callback = nil,
    bufname = command
  }, opts or {})

  -- create new terminal
  local split_cmd = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "sp") or "vsp"
  vim.cmd(string.format('%s | terminal', split_cmd))

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
  -- target_terminal config api
  set_target = set_target,
  toggle_target = toggle_target,
  send_to_target = send_to_target,
  send_content_to_target = send_content_to_target,

  -- target_terminal api
  run_target_command = run_target_command,
  run_previous_command = run_previous_command,

  add_to_palette = add_to_palette,
  run_from_palette = run_from_palette,

  -- utils
  launch_terminal = launch_terminal
}
