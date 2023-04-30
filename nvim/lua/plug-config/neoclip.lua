return {
  'AckslD/nvim-neoclip.lua',
  event = 'BufReadPre',
  requires = { 'ibhagwan/fzf-lua' },
  init = function()
    require('utils').map('n', 'gP', function()
      require('neoclip.fzf')()
    end)
  end,
  config = {
    history = 50,
    prompt = 'clipboard> ',
    enable_macro_history = false,
    default_register = {'+', '*', '"'},
    keys = {
      fzf = {
        paste = false,
        select = 'tab',
        paste_behind = 'shift-tab',
        custom = {
          ['default'] = function(opts)
            local handlers = require('neoclip/handlers')
            handlers.set_registers(opts.register_names, opts.entry)
            handlers.paste(opts.entry, 'p')
          end,
        }
      }
    }
  }
}
