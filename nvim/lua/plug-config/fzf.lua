local utils = require("utils")
local qf_populate = utils.qf_populate

vim.g.fzf_preview_window = "right:50%:+{2}-/2"
vim.g.fzf_buffers_jump = 1
vim.g.fzf_layout = {["down"] = "40%"}

vim.g.fzf_action = {
    ["ctrl-q"] = qf_populate,
    ["ctrl-x"] = "split",
    ["ctrl-v"] = "vsplit"
}

utils.map("n", "<c-p>p", "<cmd>Files<cr>")
utils.map("n", "<c-p>b", "<cmd>Buffers<cr>")
utils.map("n", "<c-p>f", "<cmd>Rg<cr>")
utils.map("n", "<c-p>z", "<cmd>Rg TODO<cr>")

vim.cmd [[
    let $FZF_DEFAULT_COMMAND = 'rg --files --follow --smart-case --hidden --no-ignore -g "!{.DS_Store,.cache,venv,.git,.clangd,.ccls-cache}" 2> /dev/null'
    let $FZF_DEFAULT_OPTS = '--bind ctrl-a:select-all,ctrl-d:deselect-all'
    autocmd! FileType fzf set laststatus=0 noruler | autocmd BufLeave <buffer> set laststatus=2 ruler
]]
