local utils = require('utils')

-- instructions: https://github.com/untitled-ai/jupyter_ascending.vim
if vim.fn.expand('%f'):match('**.sync.py') ~= nil then
    utils.map('n', '<leader>cj', '<cmd>w<cr>|<plug>JupyterExecute<cr>', { noremap = false, silent = true }, 0)
    utils.map('n', '<leader>cJ', '<cmd>w<cr>|<plug>JupyterExecuteAll<cr>', { noremap = false, silent = true }, 0)
end

