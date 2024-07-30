local core = require("lib/core")
local utils = require("utils")

local ui = session.state.ui

-- strip filename from full path
local function strip_fname(path)
  return vim.fn.fnamemodify(path, ":t:r")
end

-- strip trailing whitespaces in file
local function strip_trailing_whitespaces()
  local cursor = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_command("%s/\\s\\+$//e")
  vim.api.nvim_win_set_cursor(0, cursor)
end

-- calculate indent spaces in string
local function calculate_indent(str, get)
  local s, e = string.find(str, '^%s*')
  local indent_size = e - s + 1
  if not get then return indent_size end
  return string.rep(' ', indent_size)
end

-- scroll target buffer to end (set cursor to last line)
local function scroll_to_end(bufnr)
  local cur_win = vim.api.nvim_get_current_win()

  -- switch to buf and set cursor
  vim.api.nvim_buf_call(bufnr, function()
    local target_win = vim.api.nvim_get_current_win()
    vim.api.nvim_set_current_win(target_win)

    local target_line = vim.tbl_count(vim.api.nvim_buf_get_lines(0, 0, -1, true))
    vim.api.nvim_win_set_cursor(target_win, { target_line, 0 })
  end)

  -- return to original window
  vim.api.nvim_set_current_win(cur_win)
end

-- rename current buffer
local function rename_buffer(name)
  name = name or vim.fn.input('bufname: ', '', 'file')
  if not name then return end

  -- trivial to rename terminal buffer
  if vim.b.terminal_job_id ~= nil then
    name = 'term: ' .. name
    vim.api.nvim_buf_set_name(0, name)
    return
  end

  -- NOTE(vir): disable for other filetypes
  -- consider using command Rename from vim-eunuch
  assert(false, 'disabled for non-terminal buffers')

  -- ask for confirmation otherwise
  vim.ui.select(
    { 'yes', 'no' },
    { prompt = 'rename buffer[file] to: ' .. name .. '> ', kind = 'plain_text' },
    function(choice)
      if choice == 'yes' then
        vim.api.nvim_buf_set_name(0, name)
      end
    end
  )
end

-- window: show diff between buffer and file on disk in new tab
local function diff_current_buf()
  -- focus current buffer
  local bufnr = vim.api.nvim_get_current_buf()
  local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
  local curstate = ui.buffer_diff_state[bufnr]

  if not core.table_contains(vim.api.nvim_list_tabpages(), curstate) then
    -- reset if tabpage no longer valid
    ui.buffer_diff_state[bufnr] = false
  else
    -- NOTE(vir): this might not be the tab we actually want
    -- will fix this later if needed
    vim.api.nvim_set_current_tabpage(curstate)
    return
  end

  -- create diff split
  vim.cmd(string.format([[
    tab split
    diffthis

    topleft vnew | read # | normal! 1Gdd
    setlocal buftype=nofile
    setlocal nobuflisted
    setlocal noswapfile
    setlocal readonly!
    setlocal filetype=%s
    diffthis

    wincmd p
  ]], ft))

  -- set state
  ui.buffer_diff_state[bufnr] = vim.api.nvim_get_current_tabpage()
end


-- get winnrs for qflists visible in current tab
local function get_visible_qflists()
  return core.filter(
    vim.api.nvim_tabpage_list_wins(0),
    function(_, winnr) return vim.fn.getwininfo(winnr)[1].quickfix == 1 end
  )
end

local function linewise_macro_cmd()
  local start_line = vim.fn.line("'<")
  local end_line = vim.fn.line("'>")
  local num_lines = math.abs(end_line - start_line) + 1
  vim.api.nvim_win_set_cursor(0, { math.min(start_line, end_line), 0 })
  vim.fn.feedkeys(":" .. string.format("normal! %s@", num_lines), "n")
end

-- get git repo root dir (or nil)
local function get_git_root()
  local git_cmd = "git -C " .. vim.loop.cwd() .. " rev-parse --show-toplevel"
  local root, rc = core.lua_systemlist(git_cmd)

  if rc == 0 then
    return root[1]
  end
  return nil
end

-- get git remote names
local function get_git_remotes()
  local table, rc = core.lua_systemlist("git remote -v | cut -f 1 | uniq")
  if rc ~= 0 then
    return {}
  end

  return table
end

-- open repository on github
-- NOTE(vir): MANUAL add support for gitlab, bitbucket etc as needed
local function open_repo_on_github(remote)
  if get_git_root() == nil then
    utils.notify(
      "not in a git repository",
      "error",
      { title = "[CMD] could not open git remote" }
    )
    return
  end

  remote = remote or "origin"

  local url, rc = core.lua_system("git config remote." .. remote .. ".url")
  if rc ~= 0 then
    utils.notify(
      string.format("found invalid remote url: [%s] -> %s", remote, url),
      "error",
      { title = "[CMD] could not open git remote" }
    )
    return
  end

  assert(url, 'could not get remote urls')
  url = url:gsub("git:", "https://")
  url = url:gsub("git@", "https://")
  url = url:gsub("com:", "com/")
  url = url:gsub('ssh://', '')

  url = url:gsub('com/12051', 'com')
  core.lua_system("open " .. url)

  -- core.lua_system("open -u " .. url)

  utils.notify(
    string.format("[%s] -> %s", remote, url),
    "info",
    { title = "[CMD] open git remote in browser" }
  )
end

-- window: toggle current window (maximum <-> original)
local function toggle_window_focus()
  if vim.fn.winnr("$") > 1 then
    local original = vim.api.nvim_get_current_win()
    vim.cmd("tab split")
    ui.window_focus_state[vim.api.nvim_get_current_win()] = original
  else
    local maximized = vim.api.nvim_get_current_win()
    local original = ui.window_focus_state[maximized]

    if original ~= nil then
      vim.cmd("tabclose")
      vim.api.nvim_set_current_win(original)
      ui.window_focus_state[maximized] = nil
    end
  end
end

-- winbar: toggle context winbar in all windows
local function toggle_context_winbar()
  local callback = nil

  if session.config.context_winbar then
    callback = function(_, bufnr)
      vim.api.nvim_buf_call(
        bufnr,
        function() vim.opt_local.winbar = nil end
      )
    end
  else
    callback = function(_, bufnr)
      vim.api.nvim_buf_call(
        bufnr,
        function()
          vim.opt_local.winbar = "%!luaeval(\"require('lsp-setup/lsp_utils').get_context_winbar(" .. bufnr .. ")\")"
        end
      )
    end
  end

  core.foreach(vim.api.nvim_list_bufs(), callback)
  session.config.context_winbar = not session.config.context_winbar
end

-- inlay_hints: from lsp
local function toggle_inlay_hints()
  if ui.inlay_hints == false and vim.tbl_count(
        core.foreach(
          vim.lsp.get_clients({ bufnr = 0 }),
          function(_, client) return client.server_capabilities.inlayHintProvider end,
          true
        )
      ) > 0 then
    vim.lsp.buf.inlay_hint(0, true)
    ui.inlay_hints = true
  else
    vim.lsp.buf.inlay_hint(0, false)
    ui.inlay_hints = false
  end
end

-- separator: toggle buffer separators (thick <-> default)
local function toggle_thick_separators()
  if ui.thick_separators == true then
    vim.opt.fillchars = {
      horiz = nil,
      horizup = nil,
      horizdown = nil,
      vert = nil,
      vertleft = nil,
      vertright = nil,
      verthoriz = nil,
    }

    ui.thick_separators = false
    utils.notify("thiccness", "debug", { title = '[UI] deactivated', render = "compact" })
  else
    vim.opt.fillchars = {
      horiz = "━",
      horizup = "┻",
      horizdown = "┳",
      vert = "┃",
      vertleft = "┫",
      vertright = "┣",
      verthoriz = "╋",
    }

    ui.thick_separators = true
    utils.notify("thiccness", "info", { title = '[UI] activated', render = "compact" })
  end
end

-- spellings: toggle spellings globally
local function toggle_spellings()
  if vim.api.nvim_get_option_value("spell", { scope = "global" }) then
    vim.opt.spell = false
    utils.notify("spellings", "debug", { title = '[UI] deactivated', render = "compact" })
  else
    vim.opt.spell = true
    utils.notify("spellings", "info", { title = '[UI] activated', render = "compact" })
  end
end

-- laststatus: toggle between global and local statusline
local function toggle_global_statusline(opts)
  opts = vim.tbl_deep_extend('force', {
    force = nil -- 'local' | 'global'
  }, opts or {})

  assert(
    (opts.force and (opts.force == 'local' or opts.force == 'global')) or (not opts.force),
    'opts.force, if set, can be either "local"/"global"'
  )

  if opts.force == 'local' or
      (opts.force ~= 'global' and vim.api.nvim_get_option_value("laststatus", { scope = "global" }) == 3) then
    vim.opt.laststatus = 2
    utils.notify("global statusline", "debug", { title = '[UI] deactivated', render = "compact" })
  else
    vim.opt.laststatus = 3
    utils.notify("global statusline", "info", { title = '[UI] activated', render = "compact" })
  end
end

-- toggle between dark/light mode
local function toggle_dark_mode()
  if vim.api.nvim_get_option_value('background', { scope = 'global' }) == 'dark' then
    vim.api.nvim_set_option_value('background', 'light', { scope = 'global' })
  else
    vim.api.nvim_set_option_value('background', 'dark', { scope = 'global' })
  end

  -- reload current colorscheme
  vim.cmd.colorscheme(vim.g.colors_name)
end

-- quickfix: toggle qflist
local function toggle_qflist()
  -- open if no windows with type quickfix in current tabpage
  if vim.tbl_isempty(get_visible_qflists()) then
    vim.cmd [[ horizontal copen ]]
  else
    vim.cmd [[ cclose ]]
  end
end

-- toggle silent mode
local function toggle_silent_mode()
  session.state.ui.enable_notifications = not session.state.ui.enable_notifications
  utils.notify('silent mode', "info", { title = '[UI] activated', render = "compact" })
end

-- send :messages to qflist
local function show_messages()
  local messages = vim.api.nvim_exec("messages", true)
  local entries = {}

  for _, line in ipairs(vim.split(messages, "\n", true)) do
    table.insert(entries, { text = line })
  end

  utils.qf_populate(entries, { title = "Messages", scroll_to_end = true })
end

-- send :command output to qflist
local function show_command(out)
  local bang = out.bang
  local command = out.args

  local output = vim.api.nvim_exec(command, true)

  if bang then
    -- set to new buffer
    vim.cmd.vsplit()

    local bufnr = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_option(bufnr, 'bufhidden', 'delete')
    vim.api.nvim_win_set_buf(0, bufnr)
    vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, vim.split(output, "\n", true))
  else
    -- set to qflist
    local entries = {}
    for _, line in ipairs(vim.split(output, "\n", true)) do
      table.insert(entries, { text = line })
    end

    utils.qf_populate(entries, { title = "Command Output" })
  end
end

-- randomize colorscheme
local function random_colors()
  local mode = vim.api.nvim_get_option_value('background', { scope = 'local' })
  local choices = require('colorscheme').preferred[mode]

  local target = choices[math.random(1, #choices)]

  if type(target) == 'function' then
    local name = target()
    print("colorscheme:", name)
  else
    vim.cmd.colorscheme(target)
    print("colorscheme:", target)
  end
end

-- is buffer horizontally truncated
local function is_htruncated(width, global)
  local current_width = (global and vim.api.nvim_get_option_value('columns', { scope = 'global' })) or
      vim.api.nvim_win_get_width(0)
  return current_width <= width
end

-- is buffer vertical truncated
local function is_vtruncated(height, global)
  local current_height = (global and vim.api.nvim_get_option_value('lines', { scope = 'global' })) or
      vim.api.nvim_win_get_height(0)
  return current_height <= height
end

return {
  -- utils
  strip_fname                = strip_fname,
  strip_trailing_whitespaces = strip_trailing_whitespaces,
  calculate_indent           = calculate_indent,
  scroll_to_end              = scroll_to_end,
  rename_buffer              = rename_buffer,
  diff_current_buf           = diff_current_buf,
  get_visible_qflists        = get_visible_qflists,
  linewise_macro_cmd         = linewise_macro_cmd,

  -- git related
  get_git_root               = get_git_root,
  get_git_remotes            = get_git_remotes,
  open_repo_on_github        = open_repo_on_github,

  -- toggles
  toggle_window_focus        = toggle_window_focus,
  toggle_context_winbar      = toggle_context_winbar,
  toggle_inlay_hints         = toggle_inlay_hints,
  toggle_thick_separators    = toggle_thick_separators,
  toggle_spellings           = toggle_spellings,
  toggle_global_statusline   = toggle_global_statusline,
  toggle_dark_mode           = toggle_dark_mode,
  toggle_qflist              = toggle_qflist,
  toggle_silent_mode         = toggle_silent_mode,

  -- misc
  show_messages              = show_messages,
  show_command               = show_command,
  random_colors              = random_colors,
  is_htruncated              = is_htruncated,
  is_vtruncated              = is_vtruncated
}
