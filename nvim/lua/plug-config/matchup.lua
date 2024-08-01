return {
  'andymass/vim-matchup',
  dependencies = { 'nvim-treesitter' },
  config = function()
    vim.g.matchup_matchparen_deferred = 1
    vim.g.matchup_surround_enabled = 1
    vim.g.matchup_matchparen_offscreen = { method = 'popup' }

    -- NOTE(vir): add missing vim.b.match_words

    local utils = require("utils")
    utils.map({ 'n', 'o', 'x' }, 'Q', '<plug>(matchup-%)')
    utils.map({ 'o', 'x' }, 'iQ', '<plug>(matchup-i%)')
    utils.map({ 'o', 'x' }, 'aQ', '<plug>(matchup-a%)')
  end
}
