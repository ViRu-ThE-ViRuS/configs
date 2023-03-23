-- hello my name is viraat chandra and i love to program

require("plugins")
require("settings")
require("colorscheme")

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    require("keymaps")
    require("commands")

    -- NOTE(vir): load project local config last
    require("project_config").load()
  end
})

-- notes --
-- so $VIMRUNTIME/syntax/hitest.vim : see colors
--
-- project setup:
--  .clang-format       : clang-format config
--  .clang-tidy         : clang-tidy config
--  .flake8             : autopep8 config
--  pyrightconfig.json  : pyright config
