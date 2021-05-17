vim.cmd 'filetype plugin indent on'
vim.cmd 'syntax enable'

vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0
vim.g.python3_host_prog = vim.fn.systemlist('which python3')[1]

vim.g.gruvbox_contrast_dark = 'medium'
vim.g.gruvbox_contrast_light = 'hard'
vim.g.gruvbox_italic = 1

vim.g.moonlight_italic_comments = true
vim.g.moonlight_italic_keywords = true
vim.g.moonlight_italic_functions = true
vim.g.moonlight_italic_variables = false
vim.g.moonlight_borders = true
vim.g.moonlight_style = 'moonlight'

vim.o.background = "dark"

require('moonlight').set()
--vim.cmd 'colorscheme gruvbox'

-- gruvbox deus
-- nord OceanicNext quantum neodark
-- bluewery Tomorrow-Night-Blue
-- arcadia hybrid Tomorrow-Night-Eighties mod8
-- apprentice PaperColor luna CandyPaper jellybeans abra bogster
-- materialtheme materialbox peaksea solarized8_dark_high moonlight
-- antares afterglow codedark desertink lucid slate angr default
-- aquamarine oceanblack jellyx candycode ir_black
--
-- cake16 solarized8_light_high
-- Tomorrow eclipse autumnleaf aurora White2

-- global options
vim.o.mouse = 'a'
vim.o.modelines = 0
vim.o.history = 100
vim.o.hidden = true
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.backup = false
vim.o.writebackup = false
vim.o.autowrite = true
vim.o.lazyredraw = true
vim.o.termguicolors = true
vim.o.smarttab = true
vim.o.scrolloff = 8
vim.o.sidescrolloff = 8
vim.o.joinspaces = false
vim.o.hlsearch = false
vim.o.incsearch = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.showmode = false
vim.o.showcmd = false
vim.o.clipboard = "unnamed,unnamedplus"
vim.o.shortmess = "filnxtToOFc"
vim.o.omnifunc = "syntaxcomplete#Complete"
vim.o.display = "lastline,msgsep"
vim.o.title = true
vim.o.completeopt = "menu,noinsert,noselect,menuone"
vim.o.diffopt = 'internal,filler,vertical'
vim.o.updatetime = 1000

-- window local options
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.wo.cursorline = true
vim.wo.wrap = false
vim.wo.colorcolumn = "+1"
vim.wo.foldmethod = "manual"

-- buffer local options
vim.bo.matchpairs = "(:),{:},[:],<:>"
vim.bo.textwidth = 79
vim.bo.formatoptions = "cnjlr"
vim.bo.swapfile = false
vim.bo.undofile = true

-- vim.o.undodir = '~/.config/undodir'
vim.cmd [[
set undodir=~/.config/undodir
]]

-- vim.o.tabstop = 4
-- vim.o.softtabstop = 4
-- vim.o.shiftwidth = 4
-- vim.o.expandtab = true
-- vim.o.autoindent = true
-- vim.o.smartindent = true
vim.cmd [[
set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
set autoindent
set smartindent
]]

-- cursor setup
vim.cmd [[
if exists("tmux")
    let &t_SI="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_SR="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
    let &t_EI="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI="\<Esc>]50;CursorShape=1\x7"
    let &t_SR="\<Esc>]50;CursorShape=2\x7"
    let &t_EI="\<Esc>]50;CursorShape=0\x7"
endif
]]

