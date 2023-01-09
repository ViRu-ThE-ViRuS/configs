return {
    'folke/persistence.nvim',
    init = function()
        require('utils').add_command(
            '[MISC] Restore Session for CWD',
            function() require('persistence').load() end,
            nil,
            true
        )
    end,
    config = true
}
