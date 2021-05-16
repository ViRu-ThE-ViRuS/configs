-- deprecated
local utils = require('utils')

vim.g.gitgutter_sign_added = '|'
vim.g.gitgutter_sign_modified = '~'
vim.g.gitgutter_sign_removed = '-'
vim.g.gitgutter_map_keys = 0
vim.g.gitgutter_show_msg_on_hunk_jumping = 1

utils.map('v', '<leader>hs', '<plug>(GitGutterStageHunk)', { noremap = false})
utils.map('n', '<leader>hs', '<plug>(GitGutterStageHunk)', { noremap = false})
utils.map('n', '<leader>hu', '<plug>(GitGutterUndoHunk)', { noremap = false})
utils.map('n', '<leader>hp', '<plug>(GitGutterPreviewHunk)', { noremap = false})

utils.map('n', ']c', '<plug>(GitGutterNextHunk)', { noremap = false})
utils.map('n', '[c', '<plug>(GitGutterPrevHunk)', { noremap = false})

vim.cmd [[
autocmd! BufWritePost,BufEnter * silent! :GitGutter
]]
