vim.opt_local.buflisted = false
vim.opt_local.number = true
vim.opt_local.signcolumn = "yes"
vim.opt_local.bufhidden = "wipe"

local utils = require("utils")
utils.map("n", "<c-w>v", "<c-w><cr><c-w>L", { buffer = 0 })
utils.map("n", "<c-w>x", "<c-w><cr><c-w>K", { buffer = 0 })
utils.map("n", "<c-o>", "<cmd>wincmd p<cr>", { buffer = 0 })

vim.cmd [[ autocmd! BufEnter <buffer> if winnr('$') < 2 | q | endif ]]
