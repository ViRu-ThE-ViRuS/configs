local utils = require('utils')

-- text navigation
utils.map('v', '<', '<gv')
utils.map('v', '>', '>gv')
utils.map('n', 'H', '^')
utils.map('n', 'L', '$')
utils.map('v', 'H', '^')
utils.map('v', 'L', '$')
utils.map('i', 'jj', '<esc>')
utils.map('n', 'U', '<c-r>')

-- quickfix list
utils.map('n','[q', '<cmd>cprevious<cr>')
utils.map('n',']q', '<cmd>cnext<cr>')

-- folds
utils.map('n', '<space>', 'za')

-- buffer navigation
utils.map('n', '<c-w><c-l>', ':cclose<cr> :pclose<cr> :lclose<cr>')
utils.map('n', '<leader>t', '<cmd>bn<cr>')
utils.map('n', '<leader>o', '<c-^>', { noremap = false })
utils.map('n', '<leader>q', '<cmd>bd!<cr>')

-- buffer resizing
utils.map('n', '<m-j>', '<cmd>resize +2<cr>')
utils.map('n', '<m-k>', '<cmd>resize -2<cr>')
utils.map('n', '<m-h>', '<cmd>vertical resize -2<cr>')
utils.map('n', '<m-l>', '<cmd>vertical resize +2<cr>')

-- smoother scrolling
utils.map('n', '<ScrollWheelUp>', '<c-Y>')
utils.map('n', '<ScrollWheelDown>', '<c-E>')

-- terminal navigation
utils.map('t', '<esc>', '<c-\\><c-n>')
utils.map('t', '<c-h>', '<c-\\><c-w>h')
utils.map('t', '<c-j>', '<c-\\><c-w>j')
utils.map('t', '<c-k>', '<c-\\><c-w>k')
utils.map('t', '<c-l>', '<c-\\><c-w>l')

-- split navigation
-- TODO(vir): check plugin tmux.lua
utils.map('n', '<c-k>', '<cmd>wincmd k<cr>')
utils.map('n', '<c-j>', '<cmd>wincmd j<cr>')
utils.map('n', '<c-h>', '<cmd>wincmd h<cr>')
utils.map('n', '<c-l>', '<cmd>wincmd l<cr>')

-- hardcore mode
utils.map('n', '<up>', '<nop>')
utils.map('n', '<down>', '<nop>')
utils.map('n', '<left>', '<nop>')
utils.map('n', '<right>', '<nop>')
utils.map('i', '<up>', '<nop>')
utils.map('i', '<down>', '<nop>')
utils.map('i', '<left>', '<nop>')
utils.map('i', '<right>', '<nop>')

-- utility functions
utils.map('n', '<leader>1', '<c-w>o')
utils.map('n', '<leader>2', '<cmd>lua require("utils").RandomColors()<cr>', { silent=false })
utils.map('n', '<leader>3', '<cmd>if AutoHighlightToggle()<bar>set hlsearch<bar>endif<cr>')

-- utility maps
utils.map('n', ';', ':')
utils.map('n', ':', ';')

-- cursor, tab behaviour with completions
vim.cmd [[
    cnoreabbrev <expr> W ((getcmdtype() is# ':' && getcmdline() is# 'W')?('w'):('W'))
    cnoreabbrev <expr> Q ((getcmdtype() is# ':' && getcmdline() is# 'Q')?('q'):('Q'))
    cnoreabbrev <expr> WQ ((getcmdtype() is# ':' && getcmdline() is# 'WQ')?('wq'):('WQ'))
    cnoreabbrev <expr> Wq ((getcmdtype() is# ':' && getcmdline() is# 'Wq')?('wq'):('Wq'))

    inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
]]

-- terminal setup
if vim.fn.exists('fish') then
    vim.o.shell = 'fish'
    utils.map('n', '<leader>s', '<cmd>vsp term://fish<cr>')
elseif vim.fn.exists('zsh') then
    vim.o.shell = 'zsh'
    utils.map('n', '<leader>s', '<cmd>vsp term://zsh<cr>')
else
    vim.o.shell = 'bash'
    utils.map('n', '<leader>s', '<cmd>vsp term://bash<cr>')
end

