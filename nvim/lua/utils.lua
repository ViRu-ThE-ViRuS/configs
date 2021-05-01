local utils = {}

utils.map = function (mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then options = vim.tbl_extend('force', options, opts) end
    vim.api.nvim_set_keymap(mode, lhs, rhs, options)
end

utils.RandomColors = function()
    vim.cmd [[
    colorscheme random
    colorscheme
    ]]
end

utils.StripTrailingWhitespaces = function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    vim.api.nvim_command('%s/\\s\\+$//e')
    vim.api.nvim_win_set_cursor(0, cursor)
end

local mode_labels = {
    ['n'] = 'Normal', ['i'] = 'Insert', ['R'] = 'Replace', ['v'] = 'Visual', ['V'] = 'V-Line', ['<C-v>'] = 'V-Block',
    ['c'] = 'Command', ['s'] = 'Select', ['S'] = 'S-Line', ['<C-s>'] = 'S-Block', ['t'] = 'Terminal'
}
utils.PrettyModeName = function()
    local mode_key = vim.api.nvim_get_mode()['mode']

    if not mode_labels[mode_key] then
        return '[mode]'
    else
        return mode_labels[mode_key]
    end
end

return utils
