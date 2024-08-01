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
      utils.map('n', '<leader>iS', 'ggvG<cmd>CopilotChatToggle<cr>')
    end,
    config = function()
      require("CopilotChat").setup({
        mappings = { complete = { insert = '' } },
      })
      require("CopilotChat.integrations.cmp").setup()
    end,
  },
}
