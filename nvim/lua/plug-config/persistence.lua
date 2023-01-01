return {
    'folke/persistence.nvim',
    event = 'VimEnter',
    config = function()
        local persistence = require('persistence')

        persistence.setup()
        require('utils').add_command('[MISC] Restore Session for CWD', persistence.load, nil, true)
    end
}
