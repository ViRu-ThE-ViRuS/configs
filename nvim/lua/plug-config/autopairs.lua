return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    require('nvim-autopairs').setup {
      check_ts = true,
      fast_wrap = { map = '<m-e>', end_key = 'L' }
    }

    require('cmp').event:on(
      'confirm_done',
      require('nvim-autopairs.completion.cmp').on_confirm_done({ map_char = { tex = '' } })
    )
  end
}
