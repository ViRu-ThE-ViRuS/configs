vim.api.nvim_add_user_command('UpdateRepo', '!source update_repo.sh', {
    bang = false,
    nargs = 0,
    desc = 'Update repository with current config files'
})

vim.api.nvim_add_user_command('UpdateConfigs', '!source update_source.sh', {
    bang = false,
    nargs = 0,
    desc = 'Update configs with current repository files'
})
