local core = require("lib/core")

-- disable unused providers
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.python_host_skip_check = 1

-- set python path and shell
-- has significant performance impact due to shell cmd call to find python
-- defering this actually makes boot feel more responsive
vim.defer_fn(function()
  vim.g.python3_host_prog = core.get_python()

  local function which(cmd)
    local _, rc = core.lua_system(string.format("which %s", cmd))
    return tonumber(rc)
  end

  if which("fish") == 0 then
    vim.opt.shell = "fish"
  elseif which("zsh") == 0 then
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
vim.opt.completeopt = "menu,menuone,noinsert,popup,noselect"
vim.opt.diffopt = "internal,filler,vertical,linematch:50"
vim.opt.display = "lastline,msgsep"
vim.opt.equalalways = true
vim.opt.fillchars = vim.opt.fillchars + 'diff:╱' + 'fold: '
vim.opt.foldmarker = "{{{,}}}"
vim.opt.foldmethod = "marker" -- {{{ }}}
vim.opt.guicursor = 'n-v-c-sm:block-Cursor,i-ci-ve:ver25-Cursor,r-cr-o:hor20-Cursor'
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
vim.opt.mouse = "a"
vim.opt.number = true
vim.opt.nrformats:append('alpha')
vim.opt.path = vim.opt.path + vim.loop.cwd() + '**'
vim.opt.pumblend = 10
vim.opt.pumheight = 10
vim.opt.scrolloff = 8
vim.opt.shortmess = "filnxtToOFcs" -- .. "S" -- NOTE(vir): test out lib/search_index
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
vim.opt.wrap = false
vim.opt.writebackup = false

-- status column
vim.opt.colorcolumn = "+1"
vim.opt.cursorline = true
vim.opt.foldcolumn = 'auto:1'
vim.opt.signcolumn = "yes"
vim.opt.statuscolumn = "%s%=%{&nu?v:lnum:''} %C"

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
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.softtabstop = 2
vim.opt.swapfile = false
vim.opt.tabstop = 2
vim.opt.textwidth = 79
vim.opt.undofile = true

-- remove ft maps
vim.g.no_plugin_maps = 1
