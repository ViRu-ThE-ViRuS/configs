return {
  'AckslD/nvim-neoclip.lua',
  keys = { 'y', 'Y', 'd', 'D', 'c', 'C' }, -- load on yank
  requires = { 'ibhagwan/fzf-lua' },
  init = function()
    require('utils').map('n', 'gP', function() require('neoclip.fzf')('default') end)
  end,
  config = {
    history = 50,
    prompt = 'clipboard> ',
    enable_macro_history = false,
    keys = {
      fzf = {
        select = 'default',
        paste = 'tab',
        paste_behind = 'shift-tab',
      }
    }
  }
}
