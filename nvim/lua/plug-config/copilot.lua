return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "BufReadPre",
    opts = {
      panel = { enabled = false },
      suggestion = { enabled = false },
    }
  },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "canary",
    event = "BufReadPre",
    init = function()
      local utils = require('utils')
      utils.map({ 'n', 'x' }, '<leader>is', '<cmd>CopilotChatToggle<cr>')
      utils.map('n', '<leader>iR', '<cmd>CopilotChatReset<cr>')
      utils.map('n', '<leader>iS', 'ggvG<cmd>CopilotChatToggle<cr>')
    end,
    config = function()
      require("CopilotChat").setup({
        mappings = { complete = { insert = '' } },
        context = 'buffers',
      })

      -- nvim-cmp integration
      require("CopilotChat.integrations.cmp").setup()

      -- fzf-lua integration
      local utils = require('utils')
      local actions = require('CopilotChat.actions')
      local integration = require('CopilotChat.integrations.fzflua')
      local opts = { winopts = { split = false, height = 0.40, width = 0.50, row = 0.50, col = 0.50 } }
      utils.map({ 'n', 'v' }, '<leader>if', function() integration.pick(actions.prompt_actions(), opts) end)
      utils.map({ 'n', 'v' }, '<leader>iF', function() integration.pick(actions.help_actions(), opts) end)
    end,
  },
}
