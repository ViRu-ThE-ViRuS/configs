local utils = require("utils")
local terminal = require('terminal')

-- text navigation
utils.map("v", "<", "<gv")
utils.map("v", ">", ">gv")
utils.map("n", "H", "^")
utils.map("n", "L", "$")
utils.map("v", "H", "^")
utils.map("v", "L", "$")
utils.map("i", "jj", "<esc>")
utils.map("n", "U", "<c-r>")

-- paste yanked
utils.map("n", "-", '"0p')
utils.map("n", "_", '"0P')

-- delete without yanking
utils.map("n", "x", '"_d', {noremap=false})
utils.map("n", "X", '"_dd', {noremap=false})
utils.map("v", "x", '"_d', {noremap=false})
utils.map("v", "X", '"_dd', {noremap=false})

-- quickfix list
utils.map("n", "[q", "<cmd>try | cprev | catch | clast | catch | endtry<cr>", {silent=true})
utils.map("n", "]q", "<cmd>try | cnext | catch | cfirst | catch | endtry<cr>", {silent=true})

-- folds
utils.map("n", "<space>", "za")

-- buffer navigation
utils.map("n", "<bs>", '<c-^>zz')
utils.map("n", "<leader>t", "<cmd>bn<cr>")
utils.map("n", "<leader>q", function() require('bufdelete').bufdelete(0, true) end)
utils.map("n", "<c-w><c-l>", "<cmd>cclose<cr> <cmd>pclose<cr> <cmd>lclose<cr> <cmd>tabclose<cr>", {silent=true})

-- buffer resizing
utils.map("n", "<m-j>", "<cmd>resize +2<cr>")
utils.map("n", "<m-k>", "<cmd>resize -2<cr>")
utils.map("n", "<m-h>", "<cmd>vertical resize -2<cr>")
utils.map("n", "<m-l>", "<cmd>vertical resize +2<cr>")

-- smoother scrolling
utils.map("n", "<ScrollWheelUp>", "<c-y>")
utils.map("n", "<ScrollWheelDown>", "<c-e>")

-- sane speed scrolling
--
-- NOTE(vir): best fuccing remap ever, im so fuccing happy as this doesnt
-- require a plugin, nor does it behave unpredictably, nor does it pollute tf
-- out of the jump list, nor does it need me to install a fuccing plugin just
-- for this. im happy rn cause ive wanted to solve this problem for so long,
-- but i never really got to it and just add 2 lines to my already crazy neovim
utils.map("n", "{", "4k")
utils.map("n", "}", "4j")
-- utils.map("n", "<c-u>", "19k")
-- utils.map("n", "<c-d>", "19j")

-- terminal navigation
utils.map("t", "<esc>", "<c-\\><c-n>")
utils.map("t", "<c-h>", "<c-\\><c-w>h")
utils.map("t", "<c-j>", "<c-\\><c-w>j")
utils.map("t", "<c-k>", "<c-\\><c-w>k")
utils.map("t", "<c-l>", "<c-\\><c-w>l")

-- terminal run config maps
utils.map("n", "<leader>cA", terminal.run_target_command)
utils.map("n", "<leader>ca", terminal.run_previous_command)
utils.map("n", "<leader>cS", terminal.set_target)
utils.map("n", "<leader>cs", function() terminal.toggle_target(false) end)

-- hardcore mode
utils.map("n", "<up>", "<nop>")
utils.map("n", "<down>", "<nop>")
utils.map("n", "<left>", "<nop>")
utils.map("n", "<right>", "<nop>")
utils.map("i", "<up>", "<nop>")
utils.map("i", "<down>", "<nop>")
utils.map("i", "<left>", "<nop>")
utils.map("i", "<right>", "<nop>")

-- utility functions
utils.map("n", "<leader>1", require('lib/misc').toggle_window)
utils.map("n", "<leader>2", utils.random_colors, {silent = false})
utils.map("n", "<leader>3", "<cmd>if AutoHighlightToggle()<bar>set hlsearch<bar>endif<cr>")

-- utility maps
utils.map("n", ";", ":")
utils.map("n", ":", ";")
utils.map('n', 'Y', 'yy')

-- disable command history buffer, and EX mode
utils.map('n', 'q:', '<nop>')
utils.map('n', 'Q', '<nop>')

-- fixing that stupid typo
vim.cmd [[
    cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
    cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
    cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
    cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
]]

-- terminal setup
if vim.fn.exists("fish") then
    vim.opt.shell = "fish"
elseif vim.fn.exists("zsh") then
    vim.opt.shell = "zsh"
else
    vim.opt.shell = "bash"
end
utils.map('n', '<leader>s', '<cmd>vsp term://' .. vim.o.shell .. '<cr>')

-- tabular
utils.map('v', '<leader>=', ':Tab /')

-- fugitive
utils.map('n', '<leader>gD', '<cmd>G! difftool<cr>')

-- coconut oil remaps: messes with my . usage habits
-- utils.map("i", ",", ",<c-g>u")
-- utils.map("i", ".", ".<c-g>u")
-- utils.map("i", "!", "!<c-g>u")
-- utils.map("i", "?", "?<c-g>u")

-- flash cursorline
-- utils.map('n', '<c-o>', '<c-o>zv<cmd>lua require("utils").flash_cursorline()<cr>', { silent = true })
-- utils.map('n', '<c-i>', '<c-i>zv<cmd>lua require("utils").flash_cursorline()<cr>', { silent = true })

