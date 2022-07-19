local core = require("lib/core")

-- disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.python_host_skip_check = 1

-- set python path and shell
vim.defer_fn(function()
    vim.g.python3_host_prog = core.get_python()

    if vim.fn.exists("fish") then
        vim.opt.shell = "fish"
    elseif vim.fn.exists("zsh") then
        vim.opt.shell = "zsh"
    else
        vim.opt.shell = "bash"
    end
end, 0)

-- global options
vim.opt.autoread = true
vim.opt.autowrite = false
vim.opt.backup = false
vim.opt.clipboard = "unnamed,unnamedplus"
vim.opt.completeopt = "menu,menuone,noinsert"
vim.opt.diffopt = "internal,filler,vertical"
vim.opt.display = "lastline,msgsep"
vim.opt.equalalways = true
vim.opt.fillchars = vim.opt.fillchars + 'diff:╱' + 'fold: '
vim.opt.guicursor = 'n-v-c-sm:block,i-ci-ve:ver25,r-cr-o:hor20'
vim.opt.hidden = true
vim.opt.history = 100
vim.opt.hlsearch = false
vim.opt.ignorecase = true
vim.opt.inccommand = 'nosplit'
vim.opt.incsearch = true
vim.opt.joinspaces = false
vim.opt.joinspaces = false
vim.opt.laststatus = 3
vim.opt.lazyredraw = true
vim.opt.modelines = 0
vim.opt.mouse = "a"
vim.opt.path = vim.opt.path + "**/*"
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.scrolloff = 8
vim.opt.shortmess = "filnxtToOFc"
vim.opt.showcmd = false
vim.opt.showmode = false
vim.opt.sidescrolloff = 8
vim.opt.smartcase = true
vim.opt.smarttab = true
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.title = true
vim.opt.undodir = core.get_homedir() .. "/.config/undodir/"
vim.opt.updatetime = 1000
vim.opt.visualbell = false
vim.opt.wildmode = "full"
vim.opt.writebackup = false

-- window local
vim.opt.colorcolumn = "+1"
vim.opt.cursorline = true
vim.opt.foldcolumn = 'auto:3'
vim.opt.foldmarker = "{{{,}}}"
vim.opt.foldmethod = "marker" -- {{{ }}}
vim.opt.number = true
vim.opt.signcolumn = "yes"
vim.opt.wrap = false

-- spellings
vim.opt.spelllang = 'en_us'
vim.opt.spellsuggest = 'best'

-- buffer local
vim.opt.autoindent = true
vim.opt.expandtab = true
vim.opt.fixendofline = false
vim.opt.formatoptions = "cqnjlr"
vim.opt.matchpairs = "(:),{:},[:],<:>"
vim.opt.modelines = 5
vim.opt.shiftwidth = 4
vim.opt.smartindent = true
vim.opt.softtabstop = 4
vim.opt.swapfile = false
vim.opt.tabstop = 4
vim.opt.textwidth = 79
vim.opt.undofile = true

-- disable builtin plugins
local disabled_plugins = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "matchit",
    "matchparen",
    "netrw",
    "netrwFileHandlers",
    "netrwPlugin",
    "netrwSettings",
    "rrhelper",
    "spec",
    "spellfile_plugin",
    "tar",
    "tarPlugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin"
}

for _, plugin in ipairs(disabled_plugins) do
    vim.g['loaded_' .. plugin] = 1
end

