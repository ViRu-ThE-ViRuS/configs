-- deprecated
local utils = require('utils')

vim.g.fzf_preview_window = 'right:50%'
vim.g.fzf_buffers_jump = 1
vim.g.fzf_layout = {['down'] = '40%'}

utils.map('n', '<c-p>', '<cmd>Files<cr>')
utils.map('n', '<leader>f', '<cmd>Rg<cr>')
utils.map('n', '<leader>z', '<cmd>Rg TODO<cr>')

vim.cmd [[
let $FZF_DEFAULT_COMMAND = 'rg --files --follow --hidden --no-ignore -g "!{.DS_Store,.cache,venv,.git}" 2> /dev/null'
autocmd! FileType fzf set laststatus=0 noruler | autocmd BufLeave <buffer> set laststatus=2 ruler
]]
