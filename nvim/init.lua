-- hello my name is viraat chandra and i love to program

-- NOTE(vir): impatient.nvim
require("impatient")

require("settings")
require("colorscheme")

-- deferred execution makes the editor feel more responsive
vim.defer_fn(function()
    require("plugins")
	require("keymaps")
    require("commands")

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

