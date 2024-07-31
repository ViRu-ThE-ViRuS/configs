local misc = require('lib/misc')
local terminal = require('lib/terminal')
local quickfix = require('lib/quickfix')
local utils = require("utils")

-- line navigation and movements
utils.map("x", "<", "<gv")
utils.map("x", ">", ">gv")
utils.map({ "n", "x", "o" }, "H", "^")
utils.map({ "n", "x", "o" }, "L", "$")

-- delete without yank
utils.map({ "n", "x" }, "x", '"_d', { noremap = false })
utils.map({ "n", "x" }, "X", '"_dd', { noremap = false })
utils.map({ "n", "x" }, "<s-bs>", '"_dh', { noremap = false })
utils.map({ "n", "x" }, "<c-bs>", '"_dl', { noremap = false })

-- paste yanked
utils.map({ "n", "x" }, "-", '"0p=`]')
utils.map({ "n", "x" }, "_", '"0P=`]')

-- set undo points between each word/line
utils.map('i', '<cr>', '<c-g>u<cr>')

-- NOTE(vir): setup in commands.lua, (lib/search_index.setup)
-- utils.map('n', 'n', 'nzv', { noremap = false })
-- utils.map('n', 'N', 'Nzv', { noremap = false })

-- misc
utils.map("n", ";", ":")                                                          -- swaperoo
utils.map("n", ":", ";")                                                          -- swaperoo
utils.map("n", '`', "'")                                                          -- jump to mark (row, 0), swap
utils.map("n", "'", "`")                                                          -- jump to mark (row,col), swap
utils.map("i", "jj", "<esc>")                                                     -- home-row escape
utils.map("n", "U", "<c-r>")                                                      -- undo
utils.map('n', 'Y', 'yy')                                                         -- yank full line
utils.map("n", "<space>", "za")                                                   -- toggle folds
utils.map("n", "gp", "`[v`]")                                                     -- last paste
utils.map("n", "p", "p`[=`]")                                                     -- autoformat paste
utils.map("n", "P", "P`[=`]")                                                     -- autoformat Paste
utils.map("n", "/", "ms/")                                                        -- mark search start
utils.map("n", "?", "ms?")                                                        -- mark search start
utils.map("x", "&", ":&&<cr>")                                                    -- visual execute last substitution
utils.map("x", ".", ":normal! .<cr>")                                             -- visual execute .
utils.map("n", "ss", "s")                                                         -- substitute mode, same as default `gh`
utils.map("x", "ss", ":s/\\%V")                                                   -- substitute within visual
utils.map("x", "s/", "\"sy:%s/<c-r>s//g<left><left>")                             -- substitute selection in file
utils.map('x', '<m-/>', '<esc>/\\%V')                                             -- search within selection, '/' itself is a good mapping to consider for this
utils.map('x', '//', [[y/<c-r>=trim(escape(@",'\/]'))<cr><cr>]])                  -- search for selection
utils.map("x", "@", "<esc><cmd>lua require('lib/misc').linewise_macro_cmd()<cr>") -- run line-wise macro n times if n lines are selected

-- commandline modes
utils.map("n", '@"', "@:", { noremap = false }) -- repeat last comand
utils.map("n", '@:', "q:")                      -- command edit mode
-- utils.map({ "n", "x" }, "q:", "<nop>")
-- utils.map({ "n", "x" }, "q/", "<nop>")
-- utils.map({ "n", "x" }, "q?", "<nop>")

-- disable built ins
utils.map({ "n", "i" }, "<up>", "<nop>")
utils.map({ "n", "i" }, "<down>", "<nop>")
utils.map({ "n", "i" }, "<left>", "<nop>")
utils.map({ "n", "i" }, "<right>", "<nop>")
utils.map({ "n", "x" }, "<c-b>", "<nop>")
-- utils.map({ "n", "x" }, "<s-cr>", "<nop>")

-- disable right mouse clicks, allow left clicks for mouse placement
-- utils.map("n", "<LeftMouse>", "<nop>")
-- utils.map("n", "<2-LeftMouse>", "<nop>")
utils.map("n", "<RightMouse>", "<nop>")
utils.map("n", "<2-RightMouse>", "<nop>")

-- mouse scrolling
utils.map("n", "<ScrollWheelUp>", "<c-y>")
utils.map("n", "<ScrollWheelDown>", "<c-e>")

-- sane speed scrolling
utils.map({ "n", "x" }, "{", "4k")
utils.map({ "n", "x" }, "}", "4j")
utils.map({ "n", "x" }, "<c-u>", "20kzz")
utils.map({ "n", "x" }, "<c-d>", "20jzz")

-- fixing that stupid typo when trying to [save]exit
vim.cmd [[
    cnoreabbrev <expr> W     ((getcmdtype()  is# ':' && getcmdline() is# 'W')?('w'):('W'))
    cnoreabbrev <expr> Q     ((getcmdtype()  is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
    cnoreabbrev <expr> WQ    ((getcmdtype()  is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
    cnoreabbrev <expr> Wq    ((getcmdtype()  is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))
    cnoreabbrev <expr> w;    ((getcmdtype()  is# ':' && getcmdline() is# 'w;')?('w'):('w;'))
    cnoreabbrev <expr> ;w    ((getcmdtype()  is# ':' && getcmdline() is# ';w')?('w'):(';w'))
]]

-- toggles
utils.map("n", "<leader>1", misc.toggle_window_focus, { desc = 'toggle focus on current buffer' })
utils.map("n", "<leader>2", misc.random_colors, { desc = 'set a random preferred colorscheme' })
utils.map("n", "<leader>3", misc.toggle_global_statusline, { desc = 'toggle global statusline' })
utils.map("n", '<leader>4', misc.diff_current_buf, { desc = 'toggle unsaved changed diff' })

-- qflist keymaps
utils.map("n", "<leader>M", '<cmd>Messages<cr>')
utils.map("n", "<leader>Q", misc.toggle_qflist)
utils.map("n", "<leader>cq", quickfix.add_list)
utils.map("n", "<leader>cQ", quickfix.open_list)
utils.map("n", "[q", "<cmd>try | cprev | catch | silent! clast | catch | endtry<cr>zv")
utils.map("n", "]q", "<cmd>try | cnext | catch | silent! cfirst | catch | endtry<cr>zv")
utils.map("n", "[Q", "<cmd>try | colder | catch | endtry <cr>")
utils.map("n", "]Q", "<cmd>try | cnewer | catch | endtry <cr>")

-- buffer resizing
utils.map("n", "<m-s-j>", "<cmd>resize +2<cr>")
utils.map("n", "<m-s-k>", "<cmd>resize -2<cr>")
utils.map("n", "<m-s-h>", "<cmd>vertical resize -2<cr>")
utils.map("n", "<m-s-l>", "<cmd>vertical resize +2<cr>")

-- buffer & tab navigation
utils.map("n", "<bs>", '<c-^>zz')
utils.map("n", "[t", "<cmd>tabprev<cr>")
utils.map("n", "]t", "<cmd>tabnext<cr>")
utils.map("n", "[b", "<cmd>bprev<cr>")
utils.map("n", "]b", "<cmd>bnext<cr>")
utils.map("n", "<c-w><c-l>", "<cmd>try | cclose | pclose | lclose | tabclose | catch | endtry <cr>", { silent = true })
utils.map("n", "<c-w><c-n>", "<cmd>tabnew<cr>")

-- terminal navigation
utils.map("t", "<esc>", "<c-\\><c-n>")
utils.map("t", "<c-h>", "<c-\\><c-w>h")
utils.map("t", "<c-j>", "<c-\\><c-w>j")
utils.map("t", "<c-k>", "<c-\\><c-w>k")
utils.map("t", "<c-l>", "<c-\\><c-w>l")

-- move lines
-- utils.map('n', '<m-k>', ':move .-2<CR>==', { silent = true })
-- utils.map('n', '<m-j>', ':move .+1<CR>==', { silent = true })
utils.map('x', '<m-j>', ":move '>+1<CR>gv=gv", { silent = true })
utils.map('x', '<m-k>', ":move '<-2<CR>gv=gv", { silent = true })

-- terminal keymaps
utils.map("n", "<leader><leader>s", "<cmd>terminal<cr>")
utils.map("n", "<leader>s", "<cmd>vsp | terminal<cr>")
utils.map("n", "<leader>S", "<cmd>sp | terminal<cr>")
utils.map("n", "<leader>ca", terminal.send_to_terminal)
utils.map("n", "<leader>cA", terminal.run_command)
utils.map("n", "<leader>cs", terminal.toggle_terminal)
utils.map("n", "<leader>cS", terminal.add_terminal)
utils.map("n", "<leader>cf", terminal.select_terminal)

-- misc
utils.map({ 'n', 'x' }, '<c-cr>', vim.cmd.Commands)
utils.map('n', 'gF', '<c-w>vgf')

-- NOTE(vir): tricks
--  ins mode: <c-v> to get key code
--  these work: <c-tab>, <s-tab>, <c-s-tab>, <c-cr>, <s-cr>, <c-s-cr>
