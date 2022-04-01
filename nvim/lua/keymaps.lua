local utils = require("utils")
local terminal = require('terminal')
local misc = require('lib/misc')

-- line navigation and movements
utils.map("v", "<", "<gv")
utils.map("v", ">", ">gv")
utils.map({"n", "v", "o"}, "H", "^")
utils.map({"n", "v", "o"}, "L", "$")

-- utility maps
utils.map("i", "jj", "<esc>")
utils.map("n", "U", "<c-r>")
utils.map("n", ";", ":")
utils.map("n", ":", ";")
utils.map('n', 'Y', 'yy')
utils.map("n", "<leader>1", misc.toggle_window)
utils.map("n", "<leader>2", utils.random_colors, {silent = false})
utils.map("n", "<leader>3", "<cmd>if CWordHlToggle() | set hlsearch | endif<cr>")
utils.map("n", "<leader>4", misc.toggle_spellings)
utils.map("n", "<leader>5", misc.toggle_thicc_separators)

-- folds
utils.map("n", "<space>", "za")

-- misc
utils.map("n", "/", "ms/")
utils.map("n", "?", "ms?")
utils.map("v", "&", ":&&<cr>")
utils.map("v", ".", ":normal! .<cr>")
utils.map("v", "@", ":normal! @")
utils.map("n", "ss", "s")
utils.map("n", "gp", "`[v`]")
utils.map({"n", "v"}, "<c-b>", "<nop>")

-- delete without yank
utils.map({"n", "v"}, "x", '"_d', {noremap=false})
utils.map({"n", "v"}, "X", '"_dd', {noremap=false})
utils.map({"n", "v"}, "<a-bs>", '"_dh', {noremap=false})

-- paste yanked
utils.map("n", "-", '"0p')
utils.map("n", "_", '"0P')

-- buffer resizing
utils.map("n", "<m-j>", "<cmd>resize +2<cr>")
utils.map("n", "<m-k>", "<cmd>resize -2<cr>")
utils.map("n", "<m-h>", "<cmd>vertical resize -2<cr>")
utils.map("n", "<m-l>", "<cmd>vertical resize +2<cr>")

-- sane speed scrolling
utils.map({"n", "v"}, "{", "4k")
utils.map({"n", "v"}, "}", "4j")
utils.map({"n", "v"}, "<c-u>", "20kzz")
utils.map({"n", "v"}, "<c-d>", "20jzz")

-- mouse scrolling
utils.map("n", "<ScrollWheelUp>", "<c-y>")
utils.map("n", "<ScrollWheelDown>", "<c-e>")

-- qflist
utils.map("n", "[q", "<cmd>try | cprev | catch | clast | catch | endtry<cr>", {silent=true})
utils.map("n", "]q", "<cmd>try | cnext | catch | cfirst | catch | endtry<cr>", {silent=true})
utils.map("n", "<leader>Q", misc.toggle_qflist)

-- buffer navigation
-- NOTE(vir): bufdelete loaded after BufReadPost, causes error on fresh start
utils.map("n", "<a-[>", "<cmd>bprev<cr>")
utils.map("n", "<a-]>", "<cmd>bnext<cr>")
utils.map("n", "<bs>", '<c-^>zz')
utils.map("n", "<leader>q", function() require('bufdelete').bufdelete(0, true) end)
utils.map("n", "<c-w><c-l>", "<cmd>cclose<cr> <cmd>pclose<cr> <cmd>lclose<cr> <cmd>tabclose<cr>", {silent=true})

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
utils.map({"n", "i"}, "<up>", "<nop>")
utils.map({"n", "i"}, "<down>", "<nop>")
utils.map({"n", "i"}, "<left>", "<nop>")
utils.map({"n", "i"}, "<right>", "<nop>")

-- disable command history, EX mode
utils.map({"n", "v"}, "q:", "<nop>")
utils.map({"n", "v"}, "Q", "<cmd>normal %<cr>")

-- fixing that stupid typo when trying to [save]exit
vim.cmd [[
    cnoreabbrev <expr> W     ((getcmdtype()  is# ':' && getcmdline() is# 'W')?('w'):('W'))
    cnoreabbrev <expr> Q     ((getcmdtype()  is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
    cnoreabbrev <expr> WQ    ((getcmdtype()  is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
    cnoreabbrev <expr> Wq    ((getcmdtype()  is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
    cnoreabbrev <expr> w;    ((getcmdtype()  is# ':' && getcmdline() is# 'w;')?('w'):('w;'))
    cnoreabbrev <expr> ;w    ((getcmdtype()  is# ':' && getcmdline() is# ';w')?('w'):(';w'))
]]

-- new terminal
utils.map("n", "<leader>s", "<cmd>vsp term://" .. vim.o.shell .. "<cr>")

-- NOTE(vir): tabular
utils.map("v", "<leader>=", ":Tab /")

-- NOTE(vir): fugitive
utils.map("n", "<leader>gD", "<cmd>G! difftool<cr>")

