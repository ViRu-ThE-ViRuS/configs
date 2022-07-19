local utils = require("utils")
local terminal = require('terminal')
local misc = require('lib/misc')

-- line navigation and movements
utils.map("v", "<", "<gv")
utils.map("v", ">", ">gv")
utils.map({"n", "v", "o"}, "H", "^")
utils.map({"n", "v", "o"}, "L", "$")

-- delete without yank
-- NOTE(vir): <c-v> in insert mode, to get key code
utils.map({"n", "v"}, "x", '"_d', {noremap=false})
utils.map({"n", "v"}, "X", '"_dd', {noremap=false})
utils.map({"n", "v"}, "<a-bs>", '"_dh', {noremap=false})

-- paste yanked
utils.map({"n", "v"}, "-", '"0p=`]')
utils.map({"n", "v"}, "_", '"0P=`]')

-- misc
utils.map("n", ";", ":")                                    -- swaperoo
utils.map("n", ":", ";")                                    -- swaperoo
utils.map("i", "jj", "<esc>")                               -- home-row escape
utils.map("n", "U", "<c-r>")                                -- undo
utils.map('n', 'Y', 'yy')                                   -- yank full line
utils.map("n", "<space>", "za")                             -- toggle folds
utils.map("n", "/", "ms/")                                  -- mark search start
utils.map("n", "?", "ms?")                                  -- mark search start
utils.map("v", "&", ":&&<cr>")                              -- substitutions
utils.map("v", ".", ":normal! .<cr>")                       -- . motions
utils.map("v", "@", ":normal! @")                           -- macros
utils.map("v", "ss", ":s/")                                 -- quick subs
utils.map("n", "ss", "s")                                   -- substitute mode
utils.map("n", "p", "p=`]")                                 -- autoformat paste
utils.map("n", "P", "P=`]")                                 -- autoformat Paste
utils.map("n", "gp", "`[v`]")                               -- last paste
utils.map({"n", "v"}, "<c-b>", "<nop>")                     -- disable <c-b>

-- disable command history modes
utils.map({"n", "v"}, "q:", "<nop>")
-- utils.map({"n", "v"}, "q/", "<nop>")
-- utils.map({"n", "v"}, "q?", "<nop>")

-- mouse scrolling
utils.map("n", "<ScrollWheelUp>", "<c-y>")
utils.map("n", "<ScrollWheelDown>", "<c-e>")

-- sane speed scrolling
utils.map({"n", "v"}, "{", "4k")
utils.map({"n", "v"}, "}", "4j")
utils.map({"n", "v"}, "<c-u>", "20kzz")
utils.map({"n", "v"}, "<c-d>", "20jzz")

-- fixing that stupid typo when trying to [save]exit
vim.cmd [[
    cnoreabbrev <expr> W     ((getcmdtype()  is# ':' && getcmdline() is# 'W')?('w'):('W'))
    cnoreabbrev <expr> Q     ((getcmdtype()  is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
    cnoreabbrev <expr> WQ    ((getcmdtype()  is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
    cnoreabbrev <expr> Wq    ((getcmdtype()  is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
    cnoreabbrev <expr> w;    ((getcmdtype()  is# ':' && getcmdline() is# 'w;')?('w'):('w;'))
    cnoreabbrev <expr> ;w    ((getcmdtype()  is# ':' && getcmdline() is# ';w')?('w'):(';w'))
]]

-- hardcore mode
utils.map({"n", "i"}, "<up>", "<nop>")
utils.map({"n", "i"}, "<down>", "<nop>")
utils.map({"n", "i"}, "<left>", "<nop>")
utils.map({"n", "i"}, "<right>", "<nop>")

-- toggles
utils.map("n", "<leader>1", misc.toggle_window)
utils.map("n", "<leader>2", misc.random_colors, {silent = false})
utils.map("n", "<leader>t1", "<cmd>if CWordHlToggle() | set hlsearch | endif<cr>")
utils.map("n", "<leader>t2", misc.toggle_global_statusline)
utils.map("n", "<leader>t3", misc.toggle_thicc_separators)
utils.map("n", "<leader>t4", misc.toggle_spellings)

-- qflist navigation & toggle
utils.map("n", "[q", "<cmd>try | cprev | catch | silent! clast | catch | endtry<cr>")
utils.map("n", "]q", "<cmd>try | cnext | catch | silent! cfirst | catch | endtry<cr>")
utils.map("n", "<leader>Q", misc.toggle_qflist)

-- buffer resizing
utils.map("n", "<m-j>", "<cmd>resize +2<cr>")
utils.map("n", "<m-k>", "<cmd>resize -2<cr>")
utils.map("n", "<m-h>", "<cmd>vertical resize -2<cr>")
utils.map("n", "<m-l>", "<cmd>vertical resize +2<cr>")

-- buffer & tab navigation
-- NOTE(vir): bufdelete loaded after BufReadPost, causes error on fresh start
utils.map("n", "[t", "<cmd>tabprev<cr>")
utils.map("n", "]t", "<cmd>tabnext<cr>")
utils.map("n", "[b", "<cmd>bprev<cr>")
utils.map("n", "]b", "<cmd>bnext<cr>")
utils.map("n", "<bs>", '<c-^>zz')
utils.map("n", "<leader>q", function() require('bufdelete').bufdelete(0, true) end)
utils.map("n", "<c-w><c-l>", "<cmd>try | cclose | pclose | lclose | tabclose | catch | endtry <cr>", {silent=true})

-- terminal navigation
utils.map("t", "<esc>", "<c-\\><c-n>")
utils.map("t", "<c-h>", "<c-\\><c-w>h")
utils.map("t", "<c-j>", "<c-\\><c-w>j")
utils.map("t", "<c-k>", "<c-\\><c-w>k")
utils.map("t", "<c-l>", "<c-\\><c-w>l")

-- terminal setup
utils.map("n", "<leader>s", "<cmd>vsp term://" .. vim.o.shell .. "<cr>")
utils.map("n", "<leader>cA", terminal.run_target_command)
utils.map("n", "<leader>ca", terminal.run_previous_command)
utils.map("n", "<leader>cS", terminal.set_target)
utils.map("n", "<leader>cs", terminal.toggle_target)

-- NOTE(vir): Tabular and Fugitive Config could not find a better place for these configs
utils.map("v", "<leader>=", ":Tab /")
utils.map("n", "<leader>gD", "<cmd>G! difftool<cr>")

