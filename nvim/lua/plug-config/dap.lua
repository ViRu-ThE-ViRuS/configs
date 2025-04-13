-- {{{ helpers
-- get handles of output windows
local function activate_output_window(session)
  local utils = require('utils')
  local target_handle = nil
  local target_regex = nil

  -- NOTE(vir): MANUAL update this when new dap servers are added
  target_regex = vim.regex('\\v^.*/python3|codelldb$')

  -- get buffer handle for output window
  for _, handle in ipairs(vim.api.nvim_list_bufs()) do
    if target_regex:match_str(vim.api.nvim_buf_get_name(handle)) and
        vim.api.nvim_buf_is_loaded(handle) then
      target_handle = handle
      break
    end
  end

  -- make last output buffer active, if visible
  if target_handle then
    vim.api.nvim_buf_set_option(target_handle, 'bufhidden', 'delete')

    utils.map('n', '<c-o>', function()
      vim.cmd [[ q! ]]

      -- only close if in session tab
      if vim.api.nvim_get_current_tabpage() == session.session_target_tab and
          vim.api.nvim_tabpage_is_valid(session.session_target_tab) then
        pcall(vim.cmd, string.format('tabclose %d', session.session_target_tab))
      end
    end, { buffer = target_handle })

    local windows = vim.fn.win_findbuf(target_handle)
    if windows[#windows] then
      -- activate it if visible
      vim.api.nvim_set_current_win(windows[#windows])
    else
      -- split it otherwise
      vim.cmd('25split #' .. target_handle)
    end
  end

  return target_handle
end
-- }}}

local function setup_dap_adapters()
  local dap = require('dap')

  dap.defaults.fallback.exception_breakpoints = { 'default' }

  -- adapters
  dap.adapters.python = {
    type = 'executable',
    command = 'debugpy-adapter'
  }

  dap.adapters.codelldb = {
    type = 'server',
    port = '13000',
    executable = {
      command = 'codelldb',
      args = { '--port', '13000' },
    },
  }
end

local function setup_dap_configurations()
  local dap = require('dap')
  local core = require('lib/core')

  -- get input on runtime
  local get_program = function() return vim.fn.input('program: ', vim.loop.cwd() .. '/' .. vim.fn.expand('%f'), 'file') end
  local get_args = function() return vim.split(vim.fn.input('args: ', '', 'file'), ' ') end

  dap.configurations.python = {
    {
      type = 'python',
      request = 'launch',
      cwd = '${workspaceFolder}',
      terminal = 'console',
      console = 'integratedTerminal',
      pythonPath = core.get_python(),
      program = get_program,
      args = get_args
    }
  }

  dap.configurations.c = {
    {
      type = "codelldb",
      request = "launch",
      cwd = '${workspaceFolder}',
      terminal = 'integrated',
      console = 'integratedTerminal',
      stopOnEntry = false,
      program = get_program,
      args = get_args
    }
  }
  dap.configurations.cpp = dap.configurations.c
  dap.configurations.rust = dap.configurations.cpp
end

-- setup statuslines
local function setup_dapui_statuslines()
  local statusline = require('statusline')
  local statuslines = {
    ['dapui_watches'] = 'Watches',
    ['dapui_stacks'] = 'Stacks',
    ['dapui_scopes'] = 'Scopes',
    ['dapui_breakpoints'] = 'Breaks',
    ['dap-repl'] = 'Repl',
  }

  local wins = vim.api.nvim_tabpage_list_wins(0)
  for _, win in pairs(wins) do
    local buf = vim.api.nvim_win_get_buf(win)
    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')

    if statuslines[ft] then
      vim.api.nvim_win_set_option(win, 'statusline', statusline.set_statusline_option(statuslines[ft]))
    end
  end
end

local function setup_dap_ui()
  local dap = require('dap')
  local dapui = require('dapui')

  -- setup repl
  dap.repl.commands = vim.tbl_deep_extend('force', dap.repl.commands, {
    exit = { 'q', 'exit' },
    custom_commands = {
      ['.run_to_cursor'] = dap.run_to_cursor,
      ['.restart'] = dap.run_last
    }
  })

  -- autocomplete in repl buffer
  -- vim.api.nvim_create_autocmd('FileType', {
  --     group = 'Misc',
  --     pattern = 'dap-repl',
  --     callback = require('dap.ext.autocompl').attach
  -- })

  -- setup dapui
  dapui.setup({
    mappings = {
      expand = "<CR>",
      open = "o",
      remove = "D",
      edit = "e",
      repl = "r",
      toggle = "t",
    },
    layouts = {
      { elements = { "scopes", "breakpoints", "stacks" }, size = 0.33, position = "right" },
      { elements = { "repl", "watches" },                 size = 0.27, position = "bottom" },
    },
    icons = { expanded = "-", collapsed = "$" },
    controls = { enabled = false },
    floating = { border = "rounded", mappings = { close = { "q", "<esc>", "<c-o>" } } },
  })

  -- signs
  vim.fn.sign_define("DapStopped", { text = '=>', texthl = 'DiagnosticWarn', numhl = 'DiagnosticWarn' })
  vim.fn.sign_define("DapBreakpoint", { text = '<>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })
  vim.fn.sign_define("DapBreakpointRejected", { text = '!>', texthl = 'DiagnosticError', numhl = 'DiagnosticError' })
  vim.fn.sign_define("DapBreakpointCondition", { text = '?>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })
  vim.fn.sign_define("DapLogPoint", { text = '.>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })

  -- options
  dap.defaults.fallback.focus_terminal = false
  dap.defaults.fallback.terminal_win_cmd = '10split new'

  -- virtual text setup
  require('nvim-dap-virtual-text').setup({})
end

local function setup_dap_events()
  local dap = require('dap')
  local dapui = require('dapui')
  local utils = require('utils')

  -- remove debugging keymaps
  local function remove_maps()
    utils.unmap({ 'n', 'v' }, '<m-k>')
    utils.unmap('n', '<m-1>')
    utils.unmap('n', '<m-2>')
    utils.unmap('n', '<m-3>')
    utils.unmap('n', '<m-q>')
    utils.unmap('n', '<f4>')

    -- NOTE(vir): link this to the default location
    -- reset normal function
    utils.map("n", "<c-w><c-l>", "<cmd>try | cclose | pclose | lclose | tabclose | catch | endtry <cr>",
      { silent = true })
  end

  -- hard terminate: remove keymaps, close dapui, dap repl, dap session, output buffers
  local function hard_terminate()
    local session = dap.session()

    remove_maps()
    dapui.close()
    dap.repl.close()
    dap.close()

    if session then
      activate_output_window(session)
    end

    utils.notify(
      string.format('[PROG] %s', (session and session.config.program) or 'SESSION'),
      'debug',
      { title = '[DAP] session closed', timeout = 500 }
    )
  end

  -- setup debugging keymaps
  local function setup_maps()
    utils.map({ 'n', 'v' }, '<m-k>', dapui.eval)
    utils.map('n', '<m-1>', dap.step_over)
    utils.map('n', '<m-2>', dap.step_into)
    utils.map('n', '<m-3>', dap.step_out)

    -- hard terminate: remove keymaps, close dapui, close dap repl, close dap, delete output buffers
    utils.map('n', '<m-q>', hard_terminate)
    utils.map('n', '<c-w><c-l>', hard_terminate)

    utils.map('n', '<f4>', function()
      dapui.toggle()
      setup_dapui_statuslines()
    end)
  end

  -- start session: setup keymaps, open dapui
  local function start_session(session, _)
    if session.config.program == nil then return end
    session.session_target_tab = vim.api.nvim_get_current_tabpage()

    setup_maps()
    dapui.open()

    setup_dapui_statuslines()

    -- we reactive global statusline on exit,
    -- if we had it set before session began
    session.session_reactivate_global_statusline = vim.api.nvim_get_option_value(
      "laststatus",
      { scope = "global" }
    ) == 3

    require('lib/misc').toggle_global_statusline({ force = 'local' })

    utils.notify(
      string.format('[PROG] %s', session.config.program),
      'debug',
      { title = '[DAP] session started', timeout = 500 }
    )
  end

  -- terminate session: remove keymaps, close dapui, close dap repl, set last output buffer active
  local function terminate_session(session, _)
    if session.config.program == nil then return end

    -- reactive global statusline if it was set before session began
    if session.session_reactivate_global_statusline then
      require('lib/misc').toggle_global_statusline({ force = 'global' })
    end

    remove_maps()
    dapui.close()
    dap.repl.close()

    activate_output_window(session)

    utils.notify(
      string.format('[PROG] %s', session.config.program),
      'debug',
      { title = '[DAP] session terminated', timeout = 500 }
    )
  end

  -- dap events
  dap.listeners.before.event_initialized["dapui"] = start_session
  -- dap.listeners.before.event_terminated["dapui"] = terminate_session
  dap.listeners.before.event_exited["dapui"] = terminate_session
end

return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    "nvim-neotest/nvim-nio",
    'rcarriga/nvim-dap-ui',
    'theHamsta/nvim-dap-virtual-text',
  },
  ft = { 'c', 'cpp', 'rust', 'python' },
  init = function()
    -- launch a dap config
    local function launch_dap(config)
      local dap = require('dap')
      local opts = config._opts

      local base = require('lib/core').table_copy(dap.configurations[opts.base_type])[1]
      assert(base, "dap configuration for base type doesn't exist: " .. opts.base_type)

      -- override a copy of the base_configuration
      for key, value in pairs(config) do
        base[key] = value
      end

      -- TODO(vir): FIXME does not support long running commands
      -- preamble is called with final dap config, which will be run next
      if opts.preamble then
        opts.preamble()
      end

      -- override config params
      if opts.cwd then base.cwd = opts.cwd end

      -- run protected
      -- crashes when running dap before any buffer was opened
      -- NOTE(vir): probably a bug in dap?
      if not pcall(require('lib/core').partial(dap.run, base, { new = false })) then
        require('utils').notify(
          string.format('[PROG] %s', base.program),
          'debug',
          { title = '[DAP] session failed', timeout = 500 }
        )
      end
    end

    -- project debug config
    vim.api.nvim_create_autocmd('User', {
      group = 'Session',
      pattern = 'ProjectInit',
      callback = function()
        local project = session.state.project
        assert(project, "project should not be nil on ProjectInit")

        -- no dap configs specified
        if vim.tbl_count(project.dap_config) == 0 then return end

        -- add project command for specified configs
        project:add_command('launch project DAP config', function()
          vim.ui.select(
            (function() return vim.tbl_keys(project.dap_config) end)(),
            { prompt = 'run config> ', kind = 'plain_text' },
            function(config_name) launch_dap(project.dap_config[config_name]) end
          )
        end)
      end
    })
  end,
  config = function()
    local dap = require('dap')
    local utils = require('utils')

    -- {{{ override dap functions
    local dap_continue = dap.continue
    dap.continue = function(...)
      -- create session tab if needed
      -- if dap.session() == nil then
      --   vim.cmd('tab sb ' .. vim.api.nvim_get_current_buf())
      -- else
      --   vim.cmd('normal ' .. dap.session().session_target_tab .. 'gt')
      -- end

      dap_continue(...)
    end

    local dap_run = dap.run
    dap.run = function(...)
      -- create session tab if needed
      if dap.session() == nil then
        vim.cmd('tab sb ' .. vim.api.nvim_get_current_buf())
      else
        vim.cmd('normal ' .. dap.session().session_target_tab .. 'gt')
      end

      dap_run(...)
    end
    -- }}}

    -- NOTE(vir): use mason to install dependencies
    require('mason-nvim-dap').setup({ ensure_installed = { 'python', 'codelldb', 'lua_ls' } })

    -- setup ux
    setup_dap_adapters()
    setup_dap_configurations()
    setup_dap_ui()
    setup_dap_events()

    -- general keymaps and commands
    utils.map('n', '<m-d>b', dap.toggle_breakpoint)
    utils.map('n', '<f5>', dap.continue)

    utils.add_command('[DAP] Add conditional breakpoint', function()
      vim.ui.input({
        prompt = 'breakpoint condition> ',
        completion = 'tag'
      }, function(condition)
        dap.set_breakpoint(condition)
      end)
    end, { add_custom = true })

    utils.add_command('[DAP] Add log point', function()
      vim.ui.input({
        prompt = 'logpoint message> ',
        completion = 'tag'
      }, function(log_msg)
        dap.set_breakpoint(nil, nil, log_msg)
      end)
    end, { add_custom = true })
  end
}
