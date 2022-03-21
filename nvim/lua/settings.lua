local core = require("lib/core")

-- disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0
vim.g.python_host_skip_check = 1

-- set python path
vim.defer_fn(function() vim.g.python3_host_prog = core.get_python() end, 0)

-- use filetype.lua instead of filetype.vim
vim.g.do_filetype_lua = 1
vim.g.did_load_filetypes = 0

-- global options
vim.opt.shell = "bash"
vim.opt.mouse = "a"
vim.opt.modelines = 0
vim.opt.history = 100
vim.opt.hidden = true
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.autowrite = false
vim.opt.autoread = true
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
vim.opt.title = true
vim.opt.clipboard = "unnamed,unnamedplus"
vim.opt.shortmess = "filnxtToOFc"
vim.opt.display = "lastline,msgsep"
vim.opt.completeopt = "menu,menuone,noinsert"
vim.opt.diffopt = "internal,filler,vertical"
vim.opt.updatetime = 1000
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.equalalways = true
vim.opt.wildmode = "full"
vim.opt.visualbell = false
vim.opt.laststatus = 3
-- vim.opt.fillchars = {  horiz = '━',  horizup = '┻',  horizdown = '┳',  vert = '┃', vertleft  = '┫', vertright = '┣', verthoriz = '╋', }

-- window local
vim.opt.wrap = false
vim.opt.number = true
vim.opt.cursorline = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "+1"
vim.opt.foldmethod = "marker" -- {{{ }}}
vim.opt.foldmarker = "{{{,}}}"
-- vim.opt.foldcolumn = 'auto'

-- spellings
vim.opt.spelllang = 'en_us'
vim.opt.spellsuggest = 'best'

-- buffer local
vim.opt.formatoptions = "cqnjlr"
vim.opt.matchpairs = "(:),{:},[:],<:>"
vim.opt.textwidth = 79
vim.opt.undofile = true
vim.opt.swapfile = false
vim.opt.fixendofline = false
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4

-- TODO(vir): figure this out
-- vim.opt.exrc = true
-- vim.opt.secure = true

-- global options
vim.opt.undodir = core.get_homedir() .. "/.config/undodir/"
vim.opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'

-- disable builtin plugins
local disabled_plugins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "netrw",
    "netrwPlugin",
    "netrwSettings",
    "netrwFileHandlers",
    "matchit",
    "matchparen",
    "spec",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin"
}

for _, plugin in ipairs(disabled_plugins) do
    vim.g['loaded_' .. plugin] = 1
end

