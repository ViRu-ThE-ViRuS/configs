vim.cmd [[
    filetype plugin indent on
    syntax enable
]]

-- disable other providers
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0

-- setup python path
local handle = io.popen('which python3')
vim.g.python3_host_prog = handle:read("*a")
handle:close()

vim.g.gruvbox_contrast_dark = 'medium'
vim.g.gruvbox_contrast_light = 'hard'
vim.g.gruvbox_italic = 1

vim.g.moonlight_italic_comments = true
vim.g.moonlight_italic_keywords = true
vim.g.moonlight_italic_functions = true
vim.g.moonlight_italic_variables = false
vim.g.moonlight_borders = true
vim.g.moonlight_style = 'moonlight'

vim.g.tokyonight_sidebars = {'qf', 'terminal', 'packer', 'NvimTree', 'fugitive', 'tagbar'}
vim.g.tokyonight_italic_comments = true
vim.g.tokyonight_italic_keywords = true
vim.g.tokyonight_italic_functions = true
vim.g.tokyonight_italic_variables = false
vim.g.tokyonight_borders = true
vim.g.tokyonight_style = 'night' -- storm night

vim.o.background = "dark"
vim.o.termguicolors = true

vim.cmd [[ colorscheme nightfly ]]

-- gruvbox deus
-- nord OceanicNext quantum neodark
-- bluewery Tomorrow-Night-Blue tokyonight
-- Tomorrow-Night-Eighties apprentice luna CandyPaper jellybeans
-- materialbox solarized8_dark_high moonlight nightfly
-- antares codedark desertink default moonfly
-- aquamarine oceanblack ir_black
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
vim.o.joinspaces = false
vim.o.clipboard = "unnamed,unnamedplus"
vim.o.shortmess = "filnxtToOFc"
vim.o.omnifunc = "syntaxcomplete#Complete"
vim.o.display = "lastline,msgsep"
vim.o.title = true
vim.o.completeopt = "menu,noinsert,noselect,menuone"
vim.o.diffopt = 'internal,filler,vertical'
vim.o.updatetime = 1000
vim.o.pumblend = 10 -- transparency popup
vim.o.equalalways = true
vim.o.wildmode = "full"

-- window local options
vim.wo.number = true
vim.wo.signcolumn = 'yes'
vim.wo.cursorline = true
vim.wo.wrap = false
vim.wo.colorcolumn = "+1"
vim.wo.foldmethod = "marker" -- {{{ }}}

-- buffer local options
vim.bo.matchpairs = "(:),{:},[:],<:>"
vim.bo.textwidth = 79
vim.bo.formatoptions = "cqnjlr"
vim.bo.swapfile = false
vim.bo.undofile = true

-- TODO(vir): figure this out
-- vim.o.undodir = '~/.config/undodir'
-- vim.o.tabstop = 4
-- vim.o.softtabstop = 4
-- vim.o.shiftwidth = 4
-- vim.o.expandtab = true
-- vim.o.autoindent = true
-- vim.o.smartindent = true
vim.cmd [[
    set undodir=~/.config/undodir
    set tabstop=4
    set softtabstop=4
    set shiftwidth=4
    set expandtab
    set autoindent
    set smartindent
]]

-- cursor setup
if os.getenv('TMUX') then
    vim.cmd [[
        let &t_SI="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
        let &t_SR="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
        let &t_EI="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
    ]]
else
    vim.cmd [[
        let &t_SI="\<Esc>]50;CursorShape=1\x7"
        let &t_SR="\<Esc>]50;CursorShape=2\x7"
        let &t_EI="\<Esc>]50;CursorShape=0\x7"
    ]]
end

