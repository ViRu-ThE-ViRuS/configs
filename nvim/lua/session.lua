-- default config
local default_config = {
  context_winbar      = false,         -- set context in winbar
  fancy_notifications = true,          -- use fancy notifications (nvim-notify)
  local_rc_name       = '.nvimrc.lua', -- project local config file

  -- additional fuzzy search ignore dirs for this session
  fuzzy_ignore_dirs   = 'tags,node_modules,Pods,sessions,external',

  -- symbols and signs
  symbols             = {
    -- indicators, icons
    indicator_seperator = "",
    indicator_hint      = "[@]",
    indicator_info      = "[i]",
    indicator_warning   = "[!]",
    indicator_error     = "[x]",

    -- signs
    sign_hint           = "@",
    sign_info           = "i",
    sign_warning        = "!",
    sign_error          = "x",
  },

  -- truncation limits
  truncation          = {
    truncation_limit_s_terminal = 110, -- terminal truncation limit
    truncation_limit_s          = 80,  -- small truncation limit
    truncation_limit            = 100, -- medium truncation limit
    truncation_limit_l          = 160, -- large truncation limit
  },

  -- debug print setup
  debug_print         = {
    postfix = '__DEBUG_PRINT__',

    -- TODO(vir): support more languages as needed
    -- NOTE(vir): format string with 2 strings (%s) [label, target]
    fmt     = {
      lua    = 'print("%s: ", vim.inspect(%s))',
      c      = 'printf("%s: %%s", %s);',
      cpp    = 'std::cout << "%s: " << %s << std::endl;',
      python = 'print(f"%s: {str(%s)}")',
    },
  },

}

-- {{{ global editor state
local default_state = {
  -- contexts using lsp+ts, managed by lsp autocommands
  tags = {
    cache     = {},
    context   = {},
    req_state = {}
  },

  -- ui toggles and config
  ui = {
    thick_separators   = true, -- use thick buffer separators
    window_focus_state = {},   -- window isolation
    diagnostics_state  = {     -- diagnostics list visibility
      ["local"]  = {},
      ["global"] = false
    },
  },

  -- run_config, works with terminal api
  run_config = {
    palette         = {
      terminals = {},
      commands = {},
      indices = {}
    }
  },

  -- project-config, works with lib/project api
  project = nil,

  -- workspace commands
  commands = {}
}
-- }}}

-- NOTE(vir): initialize global session
_G.session = {
  -- config is reloaded from file
  config = default_config,

  -- state is restored from previous session, if possible
  state  = (session and vim.tbl_deep_extend('force', default_state, session.state)) or
      default_state
}

-- initialize misc features
vim.api.nvim_create_augroup('ProjectInit', { clear = true }) -- lib/project

-- NOTE(vir): return this as well
return session
