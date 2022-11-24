local utils = require('utils')

utils.add_command('UpdateRepo', function()
    vim.cmd [[
        !source update_repo.sh
        G
    ]]
end, {
    bang = false,
    nargs = 0,
    desc = 'Update repository with current config files'
}, true)

utils.add_command('UpdateConfigs', function()
    vim.ui.select({'yes', 'no'}, {prompt = 'Update System Config>'},
                  function(choice)
        if choice == 'yes' then
            vim.cmd [[ !source update_config.sh ]]
        else
            require("notify")('[config] update aborted', 'debug', {render='minimal'})
        end
    end)
end, {
    bang = true,
    nargs = 0,
    desc = 'Update configs with current repository files'
}, true)
