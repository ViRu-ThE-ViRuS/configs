-- bootstrap lazy
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--single-branch",
        "https://github.com/folke/lazy.nvim.git",
        lazypath,
    })
end
vim.opt.runtimepath:prepend(lazypath)

-- lazy config
-- plugins are loaded from lua/plug-config/*
require('lazy').setup("plug-config", {
    defaults = { lazy = true },
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
            "zipPlugin"
        }
    }
})
