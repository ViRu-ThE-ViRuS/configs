-- bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('utils').add_command('Lz', 'Lazy', {
  cmd_opts = { bang = true, nargs = 0, desc = 'Lazy' },
})

-- setup lazy
require('lazy').setup('plug-config', {
  defaults = { lazy = true },
  ui = { border = 'rounded' },
  performance = {
    rtp = {
      disabled_plugins = {
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
        "zipPlugin",

        -- these are not usually disabled
        "health",
        "man",
        "nvim",
        "rplugin",
        "shada",
        "spellfile",
        "tohtml",
        "tutor",

        "editorconfig"
      }
    }
  }
})
