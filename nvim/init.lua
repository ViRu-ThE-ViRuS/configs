-- hello my name is viraat chandra and i love to program

-- NOTE(vir): impatient.nvim
require("impatient")

require("options")
require("ui")
require("plugins")

-- load these after everything else is setup
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        require("keymaps")
        require("commands")

        -- NOTE(vir): load project local config last
        require("project_config").load()
    end
})

-- NOTE(vir): tips
--  ins mode: <c-v>                            : to get key code
--  cmd mode: so $VIMRUNTIME/syntax/hitest.vim : to see colors
