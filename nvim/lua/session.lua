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
  }
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
    thick_separators     = false, -- use thick buffer separators
    window_focus_state   = {},    -- window isolation
    buffer_diff_state    = {},    -- buffer changes diff
    enable_notifications = true,  -- like dnd mode when unset
    diagnostics_state  = {        -- diagnostics list visibility
      ["local"]  = {},
      ["global"] = false
    },
  },

  -- palette, represents the working set of files,commands, etc
  -- integrated with internal apis like project, terminal
  palette = {
    terminals = { term_states = {}, indices = {{}} },
    qf_lists = {},
    commands = {},
  },

  -- project-config, works with lib/project api
  project = nil,

  -- workspace commands
  commands = {},
}
-- }}}

-- NOTE(vir): initialize global session
_G.session = {
  -- config is reloaded from file
  config = default_config,

  -- TODO(vir): only carry over certain parts of state like commands or palette
  -- state is restored from previous session, if possible
  state  = (session and vim.tbl_deep_extend('force', default_state, session.state)) or default_state
  -- state = default_state
}

-- initialize misc features
vim.api.nvim_create_augroup('Session', { clear = true })     -- session autocommands
vim.api.nvim_create_augroup('ProjectInit', { clear = true }) -- lib/project
vim.api.nvim_create_augroup('Misc', { clear = true })        -- various hacks (preload)

-- NOTE(vir): return this as well
return session
