-- hello my name is viraat chandra and i love to program

-- for hawt reloading xd
load = function(mod)
    package.loaded[mod] = nil
    return require(mod)
end

-- impatient.nvim
load("impatient")
load("packer_compiled")

load("settings")
load("colorscheme")
load("statusline")

-- deferred execution makes the editor feel more responsive
vim.defer_fn(function()
	load("keymaps")
	load("autocommands")
	load("plugins")

	-- NOTE(vir): load this here, to keep plugins.lua clean
	load("plug-config/vista")

	-- NOTE(vir): load project local config last
	load("project_config").load()
end, 0)

-- notes --
-- so $VIMRUNTIME/syntax/hitest.vim : see colors
--
-- project setup:
--  .clang-format       : clang-format config
--  .clang-tidy         : clang-tidy config
--  .flake8             : autopep8 config
--  pyrightconfig.json  : pyright config

