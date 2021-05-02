local utils = {}

-- setup keymaps
utils.map = function (mode, lhs, rhs, opts, buffer_nr)
    local options = { noremap = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    if buffer_nr then vim.api.nvim_buf_set_keymap(buffer_nr, mode, lhs, rhs, options)
    else vim.api.nvim_set_keymap(mode, lhs, rhs, options) end
end

-- randomize colorscheme
utils.RandomColors = function()
    vim.cmd [[
    colorscheme random
    colorscheme
    ]]
end

-- strip trailing whitespaces in file
utils.StripTrailingWhitespaces = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_command('%s/\\s\\+$//e')
    vim.api.nvim_win_set_cursor(0, cursor)
end

return utils
