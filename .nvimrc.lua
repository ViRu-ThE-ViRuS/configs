vim.api.nvim_add_user_command('UpdateRepo', '!source update_repo.sh', {
    bang = false,
    nargs = 0,
    desc = 'Update repository with current config files'
})

vim.api.nvim_add_user_command('UpdateConfigs', function()
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
})
