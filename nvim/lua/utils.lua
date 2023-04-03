local core = require("lib/core")

-- setup keymaps
local function map(mode, lhs, rhs, opts)
  vim.keymap.set(
    mode,
    lhs,
    rhs,
    vim.tbl_deep_extend("force", { noremap = true }, opts or {})
  )
end

-- remove keymaps
-- returns true if a keymap was successfully removed
local function unmap(mode, lhs, options)
  return pcall(vim.keymap.del, mode, lhs, options or {})
end

-- set qflist and open
local function qf_populate(lines, mode, opts)
  if not lines or #lines == 0 then return end

  opts = vim.tbl_deep_extend('force', {
    title = nil,
    scroll_to_end = false
  }, opts or {})

  -- convenience implementation, set qf directly from values
  if (not mode) or type(mode) == "table" then

    -- set default file loc to 1:1
    lines = core.foreach(lines, function(_, item)
      return { filename = item, lnum = 1, col = 1, text = item }
    end)

    -- TODO(vir): it could be nice to have features around multiple qf lists
    -- by default, replace list
    mode = "r"
  end

  vim.fn.setqflist(lines, mode)

  -- ux
  local commands = table.concat({
    'horizontal copen',
    (opts.scroll_to_end and 'normal! G') or "",
    (opts.title and require('statusline').set_statusline_cmd(opts.title)) or "",
    'wincmd p',
  }, '\n')

  vim.cmd(commands)
end

-- notify using current notifications setup
local function notify(content, type, opts)
  local notify_fn = (session.config.fancy_notifications and require('notify')) or vim.notify
  notify_fn(content, type, opts)
end

-- add custom command
-- TODO(vir): refactor this
local function add_command(key, callback, cmd_opts, also_custom)
  -- opts are defined, create user command
  if cmd_opts then vim.api.nvim_create_user_command(key, callback, cmd_opts) end

  -- create custom command
  if also_custom then

    -- assert opts not defined, or 0 args
    assert((not cmd_opts) or (not cmd_opts.nargs) or cmd_opts.nargs == 0)

    local callback_fn = (type(callback) == 'function' and callback)
        or function() vim.api.nvim_command(callback) end

    local header_regex = vim.regex('\\v\\[.*]')
    if not header_regex:match_str(key) then key = '[CMD] ' .. key end

    session.state.commands[key] = callback_fn
  end

  return key
end

-- run custom command
local function run_command(key)
  assert(session.state.commands[key], 'command not registered in session: ' .. key)
  session.state.commands[key]()
end

return {
  map = map,
  unmap = unmap,
  qf_populate = qf_populate,
  notify = notify,
  add_command = add_command,
  run_command = run_command
}
