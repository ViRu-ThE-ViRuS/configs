local utils = require('utils')

-- instructions: https://github.com/untitled-ai/jupyter_ascending.vim
utils.map('n', '<leader>cj', '<plug>JupyterExecute<cr>', { noremap = false }, 0)
utils.map('n', '<leader>cJ', '<plug>JupyterExecuteAll<cr>', { noremap = false }, 0)
