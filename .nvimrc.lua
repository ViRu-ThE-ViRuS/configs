local utils = require('utils')
local Project = require('lib/project').Project

local project = Project.new({ name = 'ViRu-ThE-ViRuS/configs' })

project:add_command('Update Repository', function()
  vim.cmd [[
      !source update_repo.sh
      G
    ]]
end, nil, true)

project:add_command('Update Configs', function()
  vim.ui.select(
    { 'yes', 'no' },
    { prompt = 'Update System Config>' },
    function(choice)
      if choice == 'yes' then
        vim.cmd [[ !source update_config.sh ]]
      else
        project:notify('update aborted', 'debug', { render = 'minimal' })
      end
    end
  )
end, nil, true)

return project
