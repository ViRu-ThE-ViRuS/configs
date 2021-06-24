-- disable other providers
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0

-- setup python path
local handle = io.popen('which python3')
vim.g.python3_host_prog = handle:read("*a"):sub(1, -2)
handle:close()

vim.g.gruvbox_material_background = 'hard'
vim.g.gruvbox_material_enable_italic = 1
vim.g.gruvbox_contrast_dark = 'hard'
vim.g.gruvbox_contrast_light = 'hard'
vim.g.gruvbox_italic = 1

vim.g.everforest_background = 'hard'
vim.g.everforest_enable_italic = 1

vim.g.moonflyItalics = 1
vim.g.moonflyNormalFloat = 1
vim.g.moonflyUnderlineMatchParen=1

vim.o.termguicolors = true
vim.o.background = "dark"

-- can takeup a lot of startup time
vim.defer_fn(function()
    vim.cmd [[ colorscheme gruvbox-material ]]
end, 0)

-- gruvbox deus everforest
-- nord OceanicNext quantum neodark moonlight
-- bluewery Tomorrow-Night-Blue tokyonight rigel adventurous
-- Tomorrow-Night-Eighties apprentice luna CandyPaper jellybeans
-- materialbox solarized8_dark_high moonlight nightfly
-- antares codedark desertink default moonfly
-- aquamarine oceanblack ir_black
--
-- base16-black-metal-bathory gruvbox-material
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
vim.o.pumheight = 10
vim.o.equalalways = true
vim.o.wildmode = "full"

vim.wo.number = false
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

vim.o.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.autoindent = true
vim.o.smartindent = true

-- TODO(vir): figure this out
-- vim.o.undodir = '~/.config/undodir'
vim.cmd [[
    set undodir=~/.config/undodir
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
