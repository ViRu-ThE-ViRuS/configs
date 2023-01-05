return {
    'Dkendal/nvim-treeclimber',
    dependencies = { 'nvim-treesitter' },
    init = function()
        local utils = require('utils')
        utils.map('n', '<leader>uf', function() require('nvim-treeclimber').show_control_flow() end)
    end
}
