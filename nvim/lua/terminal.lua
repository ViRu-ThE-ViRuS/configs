local utils = require('utils')
local misc = require('lib/misc')

local run_config = session.state.run_config
local truncation = session.config.truncation

-- toggle target_terminal
local function toggle_target(force_open)
  if run_config.target_terminal == nil then
    utils.notify('not set', 'warn', { title = '[TERMINAL] target', render = 'compact' })
    return
  end

  local target_winid = vim.fn.bufwinid(run_config.target_terminal.bufnr)

  if target_winid ~= -1 and #vim.api.nvim_list_wins() ~= 1 then
    if force_open then return end

    -- hide target
    if not pcall(vim.api.nvim_win_close, target_winid, false) then
      utils.notify('exited, resetting state', 'debug', { title = '[TERMINAL] target', render = 'compact' })
      run_config.target_terminal = nil
    end
  else
    local split_dir = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "") or "v"

    -- open in split
    if not pcall(vim.cmd, split_dir .. 'split #' .. run_config.target_terminal.bufnr) then
      utils.notify('exited, resetting state', 'debug', { title = '[TERMINAL] target', render = 'compact' })
      run_config.target_terminal = nil
    end
  end
end

-- send payload to target_terminal
local function send_to_target(payload, repeat_last)
  if run_config.target_terminal == nil then
    utils.notify('not set', 'warn', { title = '[TERMINAL] target', render = 'compact' })
    return
  end

  if vim.api.nvim_buf_is_loaded(run_config.target_terminal.bufnr) then
    -- not using pcalls intentionally, fails successfully
    if repeat_last then
      vim.cmd("call chansend(" .. run_config.target_terminal.job_id .. ', "\x1b\x5b\x41\\<cr>")')
    else
      vim.api.nvim_chan_send(run_config.target_terminal.job_id, payload .. "\n")
    end

    -- open target terminal and scroll to bottom
    toggle_target(true)
    misc.scroll_to_end(run_config.target_terminal.bufnr)
  else
    -- buf has been unloaded
    utils.notify('does not exist, resetting state', 'debug', { title = '[TERMINAL] target', render = 'compact' })
    run_config.target_terminal = nil
  end
end

-- set target_terminal/target_command
local function set_target(default)
  if vim.b.terminal_job_id ~= nil then
    -- default is not used within a temrinal buffer
    assert(not default)

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
      { title = '[TERMINAL] target', render = "compact" }
    )
  else
    run_config.target_command = default or vim.fn.input('[terminal] target command: ', '', 'shellcmd')

    utils.notify(
      string.format("set to: %s", run_config.target_command),
      "info",
      { title = '[TERMINAL] command', render = "compact" }
    )
  end
end

-- run target_command
local function run_target_command()
  if run_config.target_command ~= "" then
    send_to_target(run_config.target_command, false)
  else
    utils.notify('command not set', 'warn', { title = '[TERMINAL] command', render = 'compact' })
  end
end

-- run previous command in target_terminal
local function run_previous_command()
  send_to_target(nil, true)
end

-- send lines to target_terminal
local function run_selection(visual_mode)
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

-- launch a terminal with the command in a split
local function launch_terminal(command, background, callback)
  assert(command, "param. command must be a valid shell command")

  local split_cmd = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "sp") or "vsp"
  vim.cmd(string.format('%s | terminal', split_cmd))

  -- terminal state
  local term_state = {
    bufnr = vim.api.nvim_get_current_buf(),
    job_id = vim.b.terminal_job_id
  }

  -- this should not crash, so pcall not needed
  vim.api.nvim_chan_send(term_state.job_id, command .. "\n")
  utils.notify(command, 'info', { title = '[TERMINAL] launched command' })

  -- wrap up
  if callback then callback() end
  if background then vim.api.nvim_win_close(vim.fn.bufwinid(term_state.bufnr), true)
  else vim.cmd [[ wincmd p ]] end

  return term_state
end

return {
  -- target_terminal config api
  toggle_target = toggle_target,
  send_to_target = send_to_target,
  set_target = set_target,
  -- target_terminal api
  run_target_command = run_target_command,
  run_previous_command = run_previous_command,
  run_selection = run_selection,
  -- general
  launch_terminal = launch_terminal
}
