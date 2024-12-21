return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "BufReadPre",
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = false }
    }
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = "BufReadPre",
    init = function()
      local utils = require('utils')
      utils.map({ 'n', 'x' }, 'ghs', '<cmd>CopilotChatToggle<cr>')
      utils.map('n', 'ghR', '<cmd>CopilotChatReset<cr>')
      utils.map('n', 'ghS', 'ggvG<cmd>CopilotChatToggle<cr>')
    end,
    build='make tiktoken',
    config = function()
      require("CopilotChat").setup({
        mappings = {
          complete = { insert = '' },
          close = { normal = 'ghs' },
          reset = { normal = '<c-r>', insert = '<c-r>' },
          show_help =  { normal = 'g?' }

        },
      })

      -- fzf-lua integration
      local utils = require('utils')
      local actions = require('CopilotChat.actions')
      local integration = require('CopilotChat.integrations.fzflua')
      local opts = { winopts = { split = false, height = 0.40, width = 0.50, row = 0.50, col = 0.50 } }
      utils.map({ 'n', 'v' }, 'ghf', function() integration.pick(actions.prompt_actions(), opts) end)
    end,
  },
}
