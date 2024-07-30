return {
  'cshuaimin/ssr.nvim',
  module = 'ssr',
  init = function()
    require('utils').map('n', 'sR', function() require('ssr').open() end)
  end,
  opts = {
    replace_confirm = "<cr>",
    replace_all = "<s-cr>",
  }
}
