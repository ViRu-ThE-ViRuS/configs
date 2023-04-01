local symbols = session.config.symbols

return {
  'rcarriga/nvim-notify',
  opts = {
    stages = 'fade',
    level = 'DEBUG',
    timeout = 150,
    fps = 20,
    icons = {
      ERROR = symbols.indicator_error,
      WARN  = symbols.indicator_warning,
      INFO  = symbols.indicator_info,
      DEBUG = symbols.indicator_hint,
      TRACE = symbols.indicator_hint
    },
    max_height = function() return math.floor(vim.o.lines * 0.50) end,
    max_width = function() return math.floor(vim.o.columns * 0.45) end,
    on_open = function(win) vim.api.nvim_win_set_config(win, { focusable = false }) end
  }
}
