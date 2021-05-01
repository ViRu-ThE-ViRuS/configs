local utils = require('utils')

vim.g.gitgutter_sign_added = '|'
vim.g.gitgutter_sign_modified = '~'
vim.g.gitgutter_sign_removed = '-'
vim.g.gitgutter_use_location_list = 1
vim.g.gitgutter_map_keys = 0

utils.map('n', '<leader>hs', '<plug>(GitGutterStageHunk)', { noremap = false})
utils.map('n', '<leader>hu', '<plug>(GitGutterUndoHunk)', { noremap = false})
utils.map('n', '<leader>hp', '<plug>(GitGutterPreviewHunk)', { noremap = false})
utils.map('n', ']c', '<plug>(GitGutterNextHunk)', { noremap = false})
utils.map('n', '[c', '<plug>(GitGutterPrevHunk)', { noremap = false})

vim.cmd [[
autocmd BufWritePost,BufEnter * silent! :GitGutter
]]
