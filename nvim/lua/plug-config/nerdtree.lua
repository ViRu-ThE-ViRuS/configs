-- deprecated
local utils = require('utils')

vim.g.NERDTreeChDirMode = 2
vim.g.NERDTreeDirArrowExpandable = '$'
vim.g.NERDTreeDirArrowCollapsible = '-'
vim.g.NERDtreeMinimalUI = 1
vim.g.NERDTreeAutoDeleteBuffer = 1

vim.g.NERDTreeIgnore = {
    '\\~$',
    '\\.pyc$',
    '^\\.DS_Store$',
    '^node_modules$',
    '^.ropeproject$',
    '^__pycache__$',
    '^venv$'
}

vim.g.NERDTreeGitStatusIndicatorMapCustom = {
    ['Modified'] = '~',
    ['Dirty'] = '~',
    ['Staged'] = '+',
    ['Untracked'] = '*',
    ['Unmerged'] = '=',
    ['Deleted'] = 'x',
    ['Clean'] = ''
}

utils.map('n', '<leader>j', '<cmd>NERDTreeToggle<cr>')
utils.map('n', '<leader>1', '<cmd>NERDTreeFind<cr>')

vim.api.nvim_exec([[
function NERDTreeBinds()
    nmap <buffer> <silent> <leader>r mm
    nmap <buffer> <silent> <leader>d md
    nmap <buffer> <silent> <leader>n ma
endfunction()

augroup NERDTree
    autocmd!
    autocmd FileType nerdtree call NERDTreeBinds()
augroup END
]], true)
