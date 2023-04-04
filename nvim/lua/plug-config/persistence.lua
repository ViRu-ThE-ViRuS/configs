return {
  'folke/persistence.nvim',
  init = function()
    require('utils').add_command(
      '[MISC] Restore Workspace Session for CWD',
      function() require('persistence').load() end,
      { add_custom = true }
    )
  end,
  config = true
}
