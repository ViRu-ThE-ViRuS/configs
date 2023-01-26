local utils = require("utils")
local terminal = require('terminal')
local misc = require('lib/misc')

-- line navigation and movements
utils.map("v", "<", "<gv")
utils.map("v", ">", ">gv")
utils.map({ "n", "v", "o" }, "H", "^")
utils.map({ "n", "v", "o" }, "L", "$")

-- delete without yank
utils.map({ "n", "v" }, "x", '"_d', { noremap = false })
utils.map({ "n", "v" }, "X", '"_dd', { noremap = false })
utils.map({ "n", "v" }, "<a-bs>", '"_dh', { noremap = false })
utils.map({ "n", "v" }, "<c-bs>", '"_dl', { noremap = false })

-- paste yanked
utils.map({ "n", "v" }, "-", '"0p=`]')
utils.map({ "n", "v" }, "_", '"0P=`]')

-- search jumps open folds, this doesnt update shortmess
-- utils.map('n', 'n', 'nzv', { noremap = false })
-- utils.map('n', 'N', 'Nzv', { noremap = false })

-- misc
utils.map("n", ";", ":")                                    -- swaperoo
utils.map("n", ":", ";")                                    -- swaperoo
utils.map("i", "jj", "<esc>")                               -- home-row escape
utils.map("n", "U", "<c-r>")                                -- undo
utils.map('n', 'Y', 'yy')                                   -- yank full line
utils.map("n", "<space>", "za")                             -- toggle folds
utils.map("n", "gp", "`[v`]")                               -- last paste
utils.map("n", "p", "p`[=`]")                               -- autoformat paste
utils.map("n", "P", "P`[=`]")                               -- autoformat Paste
utils.map({ "n", "v" }, "<c-b>", "<nop>")                   -- disable <c-b>
utils.map("n", "/", "ms/")                                  -- mark search start
utils.map("n", "?", "ms?")                                  -- mark search start
utils.map("v", "&", ":&&<cr>")                              -- visual execute last substitution
utils.map("v", ".", ":normal! .<cr>")                       -- visual execute .
utils.map("v", "@", ":normal! @")                           -- visual execute macro
utils.map("n", "ss", "s")                                   -- substitute mode
utils.map("x", "ss", ":s/\\%V")                             -- substitute in visual
utils.map("x", "s/", ":s/\\<<C-r><C-w>\\>/")                -- substitute cword in selection
utils.map('x', '//', [[y/\V<c-r>=escape(@",'/\')<cr><cr>]]) -- search for selection
utils.map('x', '<m-/>', '<esc>/\\%V')                       -- search within selection
-- utils.map('x', '/', '<esc>/\\%V') -- search within selection

-- command edit modes
-- utils.map({ "n", "v" }, "q:", "<nop>")
-- utils.map({ "n", "v" }, "q/", "<nop>")
-- utils.map({ "n", "v" }, "q?", "<nop>")
utils.map("n", '@"', "@:", { noremap = false })
utils.map("n", '@:', "q:")

-- mouse scrolling
utils.map("n", "<ScrollWheelUp>", "<c-y>")
utils.map("n", "<ScrollWheelDown>", "<c-e>")

-- disable clicks
utils.map("n", "<2-LeftMouse>", "<nop>")
utils.map("n", "<2-RightMouse>", "<nop>")
utils.map("n", "<LeftMouse>", "<nop>")
utils.map("n", "<RightMouse>", "<nop>")

-- sane speed scrolling
utils.map({ "n", "v" }, "{", "4k")
utils.map({ "n", "v" }, "}", "4j")
utils.map({ "n", "v" }, "<c-u>", "20kzz")
utils.map({ "n", "v" }, "<c-d>", "20jzz")

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
utils.map({ "n", "i" }, "<up>", "<nop>")
utils.map({ "n", "i" }, "<down>", "<nop>")
utils.map({ "n", "i" }, "<left>", "<nop>")
utils.map({ "n", "i" }, "<right>", "<nop>")

-- toggles
utils.map("n", "<leader>1", misc.toggle_window, { desc = 'toggle maximize current window' })
utils.map("n", "<leader>2", misc.random_colors, { desc = 'set a random preferred colorscheme' })
utils.map("n", "<leader>3", misc.toggle_global_statusline, { desc = 'toggle global statusline' })

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
utils.map("n", "[t", "<cmd>tabprev<cr>")
utils.map("n", "]t", "<cmd>tabnext<cr>")
utils.map("n", "[b", "<cmd>bprev<cr>")
utils.map("n", "]b", "<cmd>bnext<cr>")
utils.map("n", "<bs>", '<c-^>zz')
utils.map("n", "<c-w><c-l>", "<cmd>try | cclose | pclose | lclose | tabclose | catch | endtry <cr>", { silent = true })

-- terminal navigation
utils.map("t", "<esc>", "<c-\\><c-n>")
utils.map("t", "<c-h>", "<c-\\><c-w>h")
utils.map("t", "<c-j>", "<c-\\><c-w>j")
utils.map("t", "<c-k>", "<c-\\><c-w>k")
utils.map("t", "<c-l>", "<c-\\><c-w>l")

-- move lines
-- utils.map('n', '<a-k>', ':move .-2<CR>==', { silent = true })
-- utils.map('n', '<a-j>', ':move .+1<CR>==', { silent = true })
utils.map('v', '<a-j>', ":move '>+1<CR>gv=gv", { silent = true })
utils.map('v', '<a-k>', ":move '<-2<CR>gv=gv", { silent = true })

-- terminal setup
utils.map("n", "<leader>s", "<cmd>vsp | terminal<cr>")
utils.map("n", "<leader>cA", terminal.run_target_command)
utils.map("n", "<leader>ca", terminal.run_previous_command)
utils.map("n", "<leader>cS", terminal.set_target)
utils.map("n", "<leader>cs", terminal.toggle_target)
utils.map("n", "<leader>cv", terminal.run_selection)
utils.map("v", "<leader>cv", '<esc><cmd>lua require("terminal").run_selection(true)<cr>gv')

-- commands
utils.map('n', '<c-cr>', vim.cmd.Commands)

-- NOTE(vir): tricks
--  ins mode: <c-v> to get key code

