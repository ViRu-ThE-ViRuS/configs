-- setup fzf-lua powered lsp keymaps
local function set_lsp_keymaps(_, bufnr)
  local core = require('lib/core')
  local utils = require('utils')
  local fzf = require('fzf-lua')
  local map_opts = { silent = true, buffer = bufnr }

  utils.map("n", "<leader>us", fzf.lsp_references, map_opts)
  utils.map("n", "<leader>ud", fzf.lsp_document_symbols, map_opts)
  utils.map("n", "<leader>uD", fzf.lsp_live_workspace_symbols, map_opts)

  utils.map("n", "<leader>d", core.partial(fzf.lsp_definitions, { sync = true, jump_to_single_result = true }), map_opts)
  utils.map("n", "<leader>D", core.partial(fzf.lsp_definitions, {
    sync = true,
    jump_to_single_result = true,
    jump_to_single_result_action = fzf.actions.file_vsplit,
  }), map_opts)
end

-- custom fzf previewer
local function create_custom_previwer()
  local CustomPreviwer = require('fzf-lua.previewer.builtin').buffer_or_file:extend()

  function CustomPreviwer:new(o, opts, fzf_win)
    -- disable preview for vim.ui.select called with kind='plain_text'
    if opts._ui_select and opts._ui_select.kind == 'plain_text' then
      return nil
    end

    CustomPreviwer.super.new(self, o, opts, fzf_win)
    setmetatable(self, CustomPreviwer)
    return self
  end

  function CustomPreviwer:parse_entry(entry_str)
    local kind = (self.opts._ui_select and self.opts._ui_select.kind) or nil

    if kind == 'terminals' then
      local begin_index = string.find(entry_str, ':')
      local end_index = string.find(entry_str, ']')
      local bufnr = tonumber(string.sub(entry_str, begin_index + 1, end_index - 1))

      return {
        bufnr = bufnr,
        path = vim.api.nvim_buf_get_name(bufnr)
      }
    end

    return {}
  end

  return CustomPreviwer
end

return {
  'ibhagwan/fzf-lua',
  init = function()
    -- NOTE(vir): using require in each because it sets up lazy loading
    local utils = require('utils')
    utils.map("n", "<c-p>p", function() require('fzf-lua').files() end)

    -- defer this as it takes a bit to get git root
    vim.schedule(function()
      if require('lib/misc').get_git_root() then
        utils.map("n", "<c-p>p", function() require('fzf-lua').git_files() end)
        utils.map("n", "<c-p>P", function() require('fzf-lua').files() end)
      end
    end)

    -- fuzzy pickers
    utils.map("n", "<c-p>b", function() require('fzf-lua').buffers() end)
    utils.map("n", "<c-p>l", function() require('fzf-lua').blines() end)
    utils.map("n", "<c-p>m", function() require('fzf-lua').marks() end)
    utils.map("n", "<c-p>o", function() require('fzf-lua').resume() end)

    -- greps
    utils.map("n", "<c-p>f", function() require('fzf-lua').live_grep({ exec_empty_query = true }) end)
    utils.map("n", "<c-p>F", function() require('fzf-lua').live_grep({ continue_last_search = true }) end)
    utils.map("n", "<c-p>ss", function() require('fzf-lua').grep_cword() end)
    utils.map("n", "<c-p>sz", function() require('fzf-lua').grep({ search = 'TODO|NOTE', no_esc = true }) end)
    utils.map("v", "<c-p>ss", function() require('fzf-lua').grep_visual() end)

    -- ctags, independent of lsp
    utils.map("n", "<c-p>sP", function() require('fzf-lua').tags_grep_cword() end)
    utils.map("n", "<c-p>sp", function() require('fzf-lua').tags_live_grep({ exec_empty_query = true }) end)
    utils.map("v", "<c-p>sp", function() require('fzf-lua').tags_grep_visual() end)

    -- colorscheme selector
    utils.add_command('Colors', function() require('fzf-lua').colorschemes() end, {
      cmd_opts = { bang = false, nargs = 0, desc = 'FzfLua powered colorscheme picker' },
      add_custom = true,
    })

    -- NOTE(vir): doing here so as to force fzf
    -- custom commands
    utils.add_command("Commands", function()
      local keys = require('lib/core').apply(
        session.state.commands,
        function(key, _) return key end
      )
      table.sort(keys, function(a, b) return a > b end)

      -- force fzf-lua usage, by setting fzf-lua as vim.ui.select handler
      -- this calls config function, which sets value of vim.ui.select
      require('fzf-lua')

      vim.ui.select(keys, { prompt = "run command> ", kind = 'plain_text' }, function(key)
        if key then session.state.commands[key]() end
      end)
    end, { cmd_opts = { bang = false, nargs = 0, desc = "custom commands" } })

    -- set statusline for fzf buffers
    local statusline = require('statusline')
    vim.api.nvim_create_autocmd('FileType', {
      group = statusline.autocmd_group,
      pattern = 'fzf',
      callback = statusline.set_statusline_func('FZF'),
    })
  end,
  config = function()
    local utils = require("utils")
    local fzf = require('fzf-lua')

    local ignore_dirs = os.getenv('FZF_IGNORE_DIRS') .. ',' .. session.config.fuzzy_ignore_dirs
    local default_rg_options = string.format(' --hidden --follow --no-heading --smart-case --no-ignore -g "!{%s}"',
      ignore_dirs)

    local symbols = session.config.symbols
    local truncation = session.config.truncation
    local actions = fzf.actions

    fzf.setup({
      winopts = {
        split = 'horizontal new',
        fullscreen = false,
        preview = {
          -- default = 'bat_native',

          layout = 'flex',
          horizontal = 'right:50%',
          vertical = 'up:50%',

          -- using winopts_fn to set truncation
          -- flip_columns = truncation.truncation_limit_s_terminal

          -- builtin previewer
          scrollbar = false,
          delay = 50
        },
        on_create = function()
          vim.opt_local.buflisted = false
          vim.opt_local.bufhidden = 'wipe'

          utils.map('t', '<c-k>', '<up>', { buffer = 0 })
          utils.map('t', '<c-j>', '<down>', { buffer = 0 })
          utils.map('t', '<esc>', '<cmd>quit<cr>', { buffer = 0 })
        end,
      },
      winopts_fn = function()
        return {
          preview = {
            -- works better than flip_columns when in vsplits
            layout = (vim.api.nvim_win_get_width(0) < truncation.truncation_limit_s_terminal and 'vertical')
                or 'horizontal'
          }
        }
      end,
      fzf_opts = { ['--layout'] = 'default' },
      fzf_colors = {
        ["fg"]      = { "fg", "CursorLine" },
        ["bg"]      = { "bg", "Normal" },
        ["hl"]      = { "fg", "Comment" },
        ["fg+"]     = { "fg", "Normal" },
        ["bg+"]     = { "bg", "CursorLine" },
        ["hl+"]     = { "fg", "Statement" },
        ["info"]    = { "fg", "PreProc" },
        ["prompt"]  = { "fg", "Conditional" },
        ["pointer"] = { "fg", "Exception" },
        ["marker"]  = { "fg", "Keyword" },
        ["spinner"] = { "fg", "Label" },
        ["header"]  = { "fg", "Comment" },
        ["gutter"]  = { "bg", "Normal" },
      },
      keymap = {
        fzf = {
          ['ctrl-a']     = 'toggle-all',
          ['ctrl-f']     = 'half-page-down',
          ['ctrl-b']     = 'half-page-up',
          ['ctrl-u']     = 'beginning-of-line',
          ['ctrl-o']     = 'end-of-line',
          ['ctrl-d']     = 'abort',
          ['alt-a']      = 'select-all+accept',
          ['alt-i']      = 'clear-query', -- [right-option + delete] works on macos

          -- preview (bat)
          ['shift-down'] = 'preview-page-down',
          ['shift-up']   = 'preview-page-up'
        }
      },
      actions = {
        files = {
          ['default'] = actions.file_edit_or_qf,
          ['ctrl-x'] = actions.file_split,
          ['ctrl-v'] = actions.file_vsplit,
          ['ctrl-t'] = actions.file_tabedit,
          ['ctrl-q'] = actions.file_sel_to_qf,
        },
        buffers = {
          ['default'] = actions.buf_edit_or_qf,
          ['ctrl-x'] = actions.buf_split,
          ['ctrl-v'] = actions.buf_vsplit,
          ['ctrl-t'] = actions.buf_tabedit,
          ['ctrl-q'] = actions.buf_sel_to_qf
        }
      },
      previewers = {
        bat = {
          cmd = "bat",
          args = "--style=numbers,changes --color always",
          theme = 'Coldark-Dark'
        }
      },
      buffers = {
        actions = {
          ['ctrl-d'] = { actions.buf_del, actions.resume },
          ['ctrl-x'] = actions.buf_split, -- disable default
          ['ctrl-q'] = false              -- disable default
        }
      },
      files = {
        rg_opts = '--files' .. default_rg_options,
        git_icons = false
      },
      blines = {
        actions = { ['ctrl-q'] = actions.buf_sel_to_qf }
      },
      grep = {
        rg_glob = true,
        rg_opts = "--column --color=always" .. default_rg_options,
        actions = { ['ctrl-g'] = actions.grep_lgrep }
      },
      tags = {
        actions = { ['ctrl-g'] = actions.grep_lgrep }
      },
      lsp = {
        continue_last_search = false,
        icons = {
          ['Error'] = { icon = symbols.indicator_error, color = 'red' },
          ['Warning'] = { icon = symbols.indicator_warning, color = 'yellow' },
          ['Information'] = { icon = symbols.indicator_info, color = 'blue' },
          ['Hint'] = { icon = symbols.indicator_hint, color = 'magenta' }
        }
      }
    })

    -- set fzf-lua as vim.ui.select handler
    fzf.register_ui_select({
      previewer = create_custom_previwer(),
      winopts = {
        split  = false,
        height = 0.40,
        width  = 0.50,
        row    = 0.50,
        col    = 0.50,
      }
    }, true)
  end,

  -- export usage of this plugin
  module_exports = {
    set_lsp_keymaps = set_lsp_keymaps
  }
}
