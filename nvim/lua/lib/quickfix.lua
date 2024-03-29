local utils = require('utils')
local palette = session.state.palette

-- add list to index specified by opts.index or vim.v.count1
-- if no count is specified, refer to index 1 ie primary qflist
local function add_list(opts)
  opts = vim.tbl_deep_extend('force', {
    index = nil,
    list = nil,
  }, opts or { })

  local index = opts.index or vim.v.count1
  local list = opts.list or vim.fn.getqflist()

  if not list or vim.tbl_isempty(list) then
    utils.notify(
      'invalid list',
      'warn',
      { title = '[QF] palette ', render = 'compact' }
    )
    return
  end

  palette.qf_lists[index] = list
  utils.notify(
    string.format('list added <%d>', index),
    'info',
    { title = '[QF] palette ', render = 'compact' }
  )
end

-- set a qflist from palette
-- opts.index or vim.v.count1 is used for picking index
local function open_list(opts)
  opts = vim.tbl_deep_extend('force', { index = nil }, opts or {})
  local index = opts.index or vim.v.count1
  local list = palette.qf_lists[index]

  -- nil list is not a problem, just means index not registered
  -- no point showing empty list
  if not list or vim.tbl_isempty(list) then
    utils.notify(
      string.format('list empty <%d>', index),
      'warn',
      { title = '[QF] palette ', render = 'compact' }
    )
    return
  end

  utils.qf_populate(list)
  utils.notify(
    string.format('list set <%d>', index),
    'info',
    { title = '[QF] palette ', render = 'compact' }
  )
end

return {
  add_list = add_list,
  open_list = open_list
}
