-- hello my name is viraat chandra and i love to program

-- impatient.nvim
require("impatient")
require("packer_compiled")

require("settings")
require("colorscheme")
require("statusline")

-- deferred execution makes the editor feel more responsive
vim.defer_fn(function()
	require("keymaps")
	require("autocommands")
	require("plugins")

	-- NOTE(vir): load this here, to keep plugins.lua clean
	require("plug-config/vista")

	-- NOTE(vir): load project local config last
	require("project_config").load()
end, 0)

-- notes --
-- so $VIMRUNTIME/syntax/hitest.vim : see colors
--
-- project setup:
--  .clang-format       : clang-format config
--  .clang-tidy         : clang-tidy config
--  .flake8             : autopep8 config
--  pyrightconfig.json  : pyright config

