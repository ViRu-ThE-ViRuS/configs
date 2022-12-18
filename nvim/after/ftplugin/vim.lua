local utils = require('utils')

-- easily exit cmd edit mode from <cmd><c-f>
local function setup_cmd_edit_buf()
    local bufname = require('lib/misc').strip_fname(vim.api.nvim_buf_get_name(0))

    if bufname == '[Command Line]' then
        utils.map('n', '<c-o>', "G<cr>", { buffer = 0 })
        utils.map('n', '<c-k>', "G<cr>", { buffer = 0 })
        utils.map('n', '<esc>', "G<cr>", { buffer = 0 })
    end
end

-- setup easy exit
setup_cmd_edit_buf()

