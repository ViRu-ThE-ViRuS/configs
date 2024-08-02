local core = require('lib/core')
local utils = require('utils')
local palette = session.state.palette

local counter = 1

--- Add a list to the quickfix palette at the specified index.
-- If no index is specified, it defaults to vim.v.count.
-- If no count is given, it appends to set of stored lists.
-- If no list is specified, it defaults to the current quickfix list.
-- @param opts Table containing options for the function.
-- @param opts.index The index at which to add the list.
-- @param opts.list The list to add.
local function add_list(opts)
  opts = vim.tbl_deep_extend('force', {
    index = nil,
    list = nil,
  }, opts or {})

  local list = opts.list or vim.fn.getqflist()
  local index = opts.index or vim.v.count
  index = (index == 0 and (vim.tbl_count(palette.qf_lists) + 1)) or index
  index = (index == 0 and 1) or index

  if not list or vim.tbl_isempty(list) then
    utils.notify('invalid list', 'error', { title = '[QF] Palette ', render = 'compact' })
    return
  end

  -- Check for duplicates
  for _index, existing_list in pairs(palette.qf_lists) do
    if vim.deep_equal(list, existing_list) then
      utils.notify(string.format('duplicate list <%d>', _index), 'warn', { title = '[QF] Palette ', render = 'compact' })
      return
    end
  end

  palette.qf_lists[index] = list
  utils.notify(string.format('list added <%d>', index), 'info', { title = '[QF] Palette ', render = 'compact' })
end

--- Open a quickfix list from the palette at the specified index.
-- If no index is specified, it defaults to vim.v.count1.
-- @param opts Table containing options for the function.
-- @param opts.index The index of the list to open.
-- @param opts.silent Dont emit notifications if set to true.
local function open_list(opts)
  opts = vim.tbl_deep_extend('force', { index = nil, silent = false }, opts or {})
  local index = opts.index or vim.v.count1
  local list = palette.qf_lists[index]

  if not list or vim.tbl_isempty(list) then
    utils.notify(string.format('invalid list <%d>', index), 'error', { title = '[QF] palette ', render = 'compact' })
    return
  end

  utils.qf_populate(list)
  if not opts.silent then
    utils.notify(string.format('list set <%d>', index), 'info', { title = '[QF] palette ', render = 'compact' })
  else
    print(string.format('set qf list: <%d>', index))
  end
end

--- Create a custom FZF Lua quickfix list previewer.
-- This function extends the base previewer from fzf-lua.
-- @return The custom quickfix list previewer.
local function create_fzflua_qflist_previewer()
  local QFListPreviewer = require('fzf-lua.previewer.builtin').base:extend()

  function QFListPreviewer:new(o, opts, fzf_win)
    QFListPreviewer.super.new(self, o, opts, fzf_win)
    setmetatable(self, QFListPreviewer)
    return self
  end

  function QFListPreviewer:populate_preview_buf(entry_str)
    local list = palette.qf_lists[tonumber(string.match(entry_str, "List #%[(%d+)%]"))]

    local lines = {}
    for _, item in ipairs(list) do
      local filename = vim.api.nvim_buf_get_name(item.bufnr)
      local list_entry = (item.text ~= "" and string.format("%s | %s", filename, item.text)) or filename
      table.insert(lines, list_entry)
    end

    local tmpbuf = self:get_tmp_buffer()
    vim.api.nvim_buf_set_lines(tmpbuf, 0, -1, false, lines)
    self:set_preview_buf(tmpbuf)
    self.win:update_scrollbar()
  end

  return QFListPreviewer
end

--- Select a quickfix list using vim.ui.select and open it.
-- If fzf-lua is available, it uses fzf-lua for selection.
local function select_list()
  local indices = {}
  for index, _ in pairs(palette.qf_lists) do
    table.insert(indices, index)
  end

  if vim.tbl_isempty(indices) then
    utils.notify('no lists available', 'warn', { title = '[QF] palette ', render = 'compact' })
    return
  end

  local choices = core.foreach(indices, function(_, index)
    return string.format('List #[%d]', index)
  end, true)

  local use_fzf, fzf = pcall(require, 'fzf-lua')
  if use_fzf then
    fzf.fzf_exec(choices, {
      prompt = '[QF] Palette ❯ ',
      previewer = create_fzflua_qflist_previewer(),
      actions = {
        ['default'] = function(selected, _)
          if not selected then return end
          local index = tonumber(string.match(selected[1], "List #%[(%d+)%]"))
          open_list({ index = index })
        end
      },
      fzf_opts = { ["--header"] = 'Set QuickFix To: ' },
    })
  else
    vim.ui.select(choices, {
      prompt = '[QF] Palette > ',
      kind = 'plain_text',
    }, function(selected)
      if not selected then return end
      local index = tonumber(string.match(selected, "List #%[(%d+)%]"))
      open_list({ index = index })
    end)
  end
end

--- Set the next quickfix list from the palette.
-- This function cycles through the available lists.
local function set_next_list()
  local num_lists = vim.tbl_count(palette.qf_lists)
  if num_lists == 0 then
    utils.notify('no lists available', 'warn', { title = '[QF] palette ', render = 'compact' })
    return
  end

  open_list({ index = counter, silent = true })
  counter = counter % num_lists + 1
end

--- Set the previous quickfix list from the palette.
-- This function cycles through the available lists in reverse order.
local function set_previous_list()
  local num_lists = vim.tbl_count(palette.qf_lists)
  if num_lists == 0 then
    utils.notify('no lists available', 'warn', { title = '[QF] palette ', render = 'compact' })
    return
  end

  open_list({ index = counter, silent = true })
  counter = (counter - 2 + num_lists) % num_lists + 1
end

return {
  add_list = add_list,
  open_list = open_list,
  select_list = select_list,
  set_next_list = set_next_list,
  set_previous_list = set_previous_list,
}
