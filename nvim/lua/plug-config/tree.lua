local function open_in_finder(handle) require('lib/core').lua_system("open -R " .. handle.absolute_path) end

local function on_attach(bufnr)
  local api = require('nvim-tree.api')
  local opts = { buffer = bufnr, silent = true, nowait = true }

  vim.keymap.set('n', '<cr>', api.node.open.edit, opts)
  vim.keymap.set('n', '<2-leftmouse>', api.node.open.edit, opts)
  vim.keymap.set('n', '<c-v>', api.node.open.vertical, opts)
  vim.keymap.set('n', '<c-x>', api.node.open.horizontal, opts)
  vim.keymap.set('n', '<bs>', api.node.navigate.parent_close, opts)
  vim.keymap.set('n', 'J', api.node.navigate.parent, opts)
  vim.keymap.set('n', '[c', api.node.navigate.git.prev, opts)
  vim.keymap.set('n', ']c', api.node.navigate.git.next, opts)
  vim.keymap.set('n', 'I', api.tree.toggle_hidden_filter, opts)
  vim.keymap.set('n', 'R', api.tree.reload, opts)
  vim.keymap.set('n', 'C', api.tree.change_root_to_node, opts)
  vim.keymap.set('n', 'q', api.tree.close, opts)
  vim.keymap.set('n', 'f', api.live_filter.start, opts)
  vim.keymap.set('n', 'F', api.live_filter.clear, opts)
  vim.keymap.set('n', 'Y', api.fs.copy.absolute_path, opts)
  vim.keymap.set('n', '<leader>n', api.fs.create, opts)
  vim.keymap.set('n', '<leader>d', api.fs.remove, opts)
  vim.keymap.set('n', '<leader>r', api.fs.rename_sub, opts)
  vim.keymap.set('n', 'OO', function()
    local node = api.tree.get_node_under_cursor()
    open_in_finder(node)
  end, opts)

  require("utils").map("n", "/", function()
    local fzf = require("fzf-lua")
    local ignore_dirs = session.config.fuzzy_ignore_dirs
    fzf.fzf_exec(string.format('rg --files --hidden --glob "!%s"', ignore_dirs), {
      prompt = "Tree> ",
      fzf_opts = { ["--padding"] = "5%,5%,15%,5%" },
      winopts = { height = 0.15, width = vim.fn.winwidth(0) - 2, row = 1, col = 1, title = " search tree " },
      actions = {
        ["default"] = {
          fn = function(selected)
            require("nvim-tree.api").tree.find_file(selected[1])
          end,
          desc = "fuzzy find in tree",
        },
      },
    })
  end, opts)
end

return {
  'kyazdani42/nvim-tree.lua',
  cmd = 'NvimTreeToggle',
  init = function()
    local utils = require('utils')
    utils.map('n', '<leader>j', '<cmd>NvimTreeToggle<cr>')

    vim.api.nvim_create_autocmd('FileType', {
      group = 'Misc',
      pattern = { 'NvimTree' },
      callback = function()
        utils.map('n', '<c-o>', '<cmd>wincmd p<cr>', { buffer = 0 })
      end,
    })

    -- set statusline for nvim-tree buffers
    local statusline = require('statusline')
    vim.api.nvim_create_autocmd('BufWinEnter', {
      group = statusline.autocmd_group,
      pattern = 'NvimTree_*',
      callback = function()
        vim.opt_local.statuscolumn = ''
        statusline.set_statusline_func('Explorer')()
      end,
    })
  end,
  opts = {
    update_focused_file = { enable = true, update_cwd = false },
    diagnostics = { enable = false },
    filters = {
      custom = { '*.pyc', '.DS_Store', 'node_modules', '__pycache__', 'venv', '*.dSYM' },
      -- exclude = { 'gitignore', 'gitmodules' }
    },
    on_attach = on_attach,
    git = { ignore = false },
    renderer = {
      indent_markers = { enable = true },
      add_trailing = true,
      full_name = true,
      group_empty = true,
      icons = {
        show = { git = true, folder = true, file = false },
        glyphs = {
          -- folder = {
          --     default = '-',
          --     open = '-',
          --     empty = '-',
          -- },
          default = '',
          git = {
            unstaged  = '~',
            staged    = '+',
            unmerged  = '=',

            untracked = '*',
            deleted   = 'x',
            ignored   = '.',
            renamed   = '>'
          }
        }
      }
    },
    actions = {
      open_file = {
        window_picker = {
          exclude = {
            filetype = { 'packer', 'qf', 'fugitive', 'Outline', 'vista', 'diagnostics' },
            buftype = { 'terminal', 'nofile', 'help' }
          }
        }
      }
    }
  }
}
