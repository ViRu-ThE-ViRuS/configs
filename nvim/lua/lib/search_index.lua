-- track current extmark
local search_count_extmark_id = nil

-- clear searchcount virtualtext
local function clear_search_index()
  local namespace_id = vim.api.nvim_get_namespaces()['search']
  if search_count_extmark_id then
    vim.api.nvim_buf_del_extmark(0, namespace_id, search_count_extmark_id)
  end
end

-- show virtual text searchount
local function show_search_index()
  local search_count = vim.fn.searchcount()
  local namespace_id = vim.api.nvim_create_namespace('search')
  vim.api.nvim_buf_clear_namespace(0, namespace_id, 0, -1)

  -- search.count.total < 1: no matches, dont show search index
  -- search_count.incomplete == 1: recomputing / timed out ie invalid result
  if search_count.total < 1 or search_count.incomplete == 1 then return end

  search_count_extmark_id = vim.api.nvim_buf_set_extmark(0, namespace_id, vim.api.nvim_win_get_cursor(0)[1] - 1, 0, {
    virt_text = { { string.format(
      '[ %s/%s ]',
      search_count.current,

      -- search_count.incomplete == 2: means max_count exceeded, unkonwn #matches
      ((search_count.incomplete == 2 and '>=') or '') ..  search_count.total
    ), "StatusLine" } },
    virt_text_pos = "eol",
  })

  vim.cmd("redraw")
end

-- setup keymaps and commands
local function setup()
  -- set search index when using / or ?
  vim.api.nvim_create_autocmd('CmdlineLeave', {
    group = 'Misc',
    callback = function(event)
      if event.match == '/' or event.match == '?' then
        vim.defer_fn(show_search_index, 0)
      end
    end
  })

  -- clear serach index when leaving buffer
  vim.api.nvim_create_autocmd({'BufLeave', 'BufWritePre'}, {
    group = 'Misc',
    callback = clear_search_index
  })

  -- get function which will execute key and show search index
  local function show_index_on(key)
    return function()
      if pcall(vim.cmd, 'silent! normal! ' .. key .. 'zv') then
        vim.defer_fn(show_search_index, 0)
      else
        clear_search_index()
      end
    end
  end

  local utils = require('utils')
  utils.map('n', 'n', show_index_on('n'))
  utils.map('n', 'N', show_index_on('N'))
  utils.map('n', '*', show_index_on('*'))
  utils.map('n', '#', show_index_on('#'))
  utils.map('n', 'g*', show_index_on('g*'))
  utils.map('n', 'g#', show_index_on('g#'))
  utils.map('n', 'c/', clear_search_index)
end


return { setup = setup }
