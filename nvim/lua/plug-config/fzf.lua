local utils = require('utils')

vim.g.fzf_preview_window = 'right:50%'
vim.g.fzf_buffers_jump = 1
vim.g.fzf_layout = {['down'] = '40%'}

utils.map('n', '<c-p>', '<cmd>Files<cr>')
utils.map('n', '<leader>f', '<cmd>Rg<cr>')
utils.map('n', '<leader>z', '<cmd>Rg TODO<cr>')

vim.cmd [[
    let $FZF_DEFAULT_COMMAND = 'rg --files --follow --smart-case --hidden --no-ignore -g "!{.DS_Store,.cache,venv,.git}" 2> /dev/null'
    let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all'
    autocmd! FileType fzf set laststatus=0 noruler | autocmd BufLeave <buffer> set laststatus=2 ruler

    function! FZF_Build_QfList(lines)
        call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
        copen
        cc
    endfunction

    let g:fzf_action = { 'ctrl-q': function('FZF_Build_QfList'), 'ctrl-x': 'split', 'ctrl-v': 'vsplit' }
]]

