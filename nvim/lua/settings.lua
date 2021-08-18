-- disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0

-- setup python path
local handle = io.popen('which python3')
vim.g.python3_host_prog = handle:read("*a"):sub(1, -2)
handle:close()

-- global options
vim.opt.shell = 'bash'
vim.opt.mouse = 'a'
vim.opt.modelines = 0
vim.opt.history = 100
vim.opt.hidden = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.autowrite = true
vim.opt.lazyredraw = true
vim.opt.termguicolors = true
vim.opt.smarttab = true
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.joinspaces = false
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.showmode = false
vim.opt.showcmd = false
vim.opt.joinspaces = false
vim.opt.clipboard = "unnamed,unnamedplus"
vim.opt.shortmess = "filnxtToOFc"
vim.opt.omnifunc = "syntaxcomplete#Complete"
vim.opt.display = "lastline,msgsep"
vim.opt.title = true
vim.opt.completeopt = "menu,noinsert,noselect,menuone"
vim.opt.diffopt = 'internal,filler,vertical'
vim.opt.updatetime = 1000
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.equalalways = true
vim.opt.wildmode = "full"

vim.opt.number = false
vim.opt.signcolumn = 'yes'
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.colorcolumn = "+1"
vim.opt.foldmethod = "marker" -- {{{ }}}

-- buffer local options
vim.opt.formatoptions = "cqnjlr"
vim.opt.matchpairs = "(:),{:},[:],<:>"
vim.opt.textwidth = 79
vim.opt.swapfile = false
vim.opt.undofile = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true

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
