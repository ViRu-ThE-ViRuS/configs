local core = require("lib/core")

-- setup keymaps
local function map(mode, lhs, rhs, opts)
  local options = { noremap = true }
  if opts then options = vim.tbl_extend("force", options, opts) end
  vim.keymap.set(mode, lhs, rhs, options)
end

-- remove keymaps
local function unmap(mode, lhs, options)
  options = options or {}

  -- vim.keymap.del(mode, lhs, options)
  pcall(vim.keymap.del, mode, lhs, options)
end

-- set qflist and open
local function qf_populate(lines, mode, title, scroll_to_end)
  if not lines or #lines == 0 then return end

  if mode == nil or type(mode) == "table" then
    lines = core.foreach(lines, function(_, item) return { filename = item, lnum = 1, col = 1, text = item } end)
    mode = "r"
  end

  vim.fn.setqflist(lines, mode)

  local commands = {
    'horizontal copen',
    (scroll_to_end and 'normal! G') or "",
    (title and require('statusline').set_statusline_cmd(title)) or "",
    'wincmd p'
  }

  vim.cmd(table.concat(commands, '\n'))
end

-- notify using current notifications setup
local function notify(content, type, opts)
  local notify_fn = (session.config.fancy_notifications and require('notify')) or vim.notify
  notify_fn(content, type, opts)
end

-- add custom command
local function add_command(key, callback, cmd_opts, also_custom)
  -- opts defined, create user command
  if cmd_opts and next(cmd_opts) then
    vim.api.nvim_create_user_command(key, callback, cmd_opts)
    key = '[CMD] ' .. key
  end

  -- create custom command
  if also_custom then
    -- assert opts not defined, or 0 args
    assert((not cmd_opts) or (not cmd_opts.nargs) or cmd_opts.nargs == 0)

    local callback_fn = (type(callback) == 'function' and callback) or function()
          vim.api.nvim_command(callback)
        end
    session.state.commands[key] = callback_fn
  end
end

return {
  map = map,
  unmap = unmap,
  qf_populate = qf_populate,
  notify = notify,
  add_command = add_command,
}
