local utils = require('utils')
local core = require('lib/core')

local function jump_to_query(direction)
  local current_line = vim.fn.line('.')
  local total_lines = vim.fn.line('$')

  local start = current_line + ((direction == 'next' and 1) or -1)
  local stop = ((direction == 'next' and total_lines) or 1)
  local step = ((direction == 'next' and 1) or -1)

    for i = start, stop, step do
      local line_content = vim.fn.getline(i)
      if line_content:match("^## %S") then
        vim.fn.cursor(i, 1)
        return
      end
    end
end

utils.map("n", "[i", core.partial(jump_to_query, 'previous'), { buffer = 0 })
utils.map("n", "]i", core.partial(jump_to_query, 'next'), { buffer = 0 })

vim.api.nvim_create_autocmd('BufEnter', {
  group = 'Misc',
  pattern = 'copilot-chat',
  callback = function()
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false
    -- vim.api.nvim_command('set filetype=markdown')
  end
})

