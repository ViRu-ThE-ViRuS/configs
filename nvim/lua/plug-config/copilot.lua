# inspired by https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua
local prompts = {
  -- Text related prompts
  Summarize = "Please summarize the following text.",
  Spelling = "Please correct any grammar and spelling errors in the following text.",
  Wording = "Please improve the grammar and wording of the following text.",
  Concise = "Please rewrite the following text to make it more concise.",

  -- Code related prompts
  Explain = "Please explain how the following code works.",
  Review = "Please review the following code and provide suggestions for improvement.",
  Tests = "Please explain how the selected code works, then generate unit tests for it.",
  Refactor = "Please refactor the following code to improve its clarity and readability.",
  FixCode = "Please fix the following code to make it work as intended.",
  FixError = "Please explain the error in the following text and provide a solution.",
  BetterNamings = "Please provide better names for the following variables and functions.",
  Documentation = "Please provide documentation for the following code.",

  -- misc
  Pythonize =
  "Please update the selected code to use latest pythonic patterns. Write minimal and easy-to-understand code. Prefer built-in libraries, use third-party libs if they significantly improve performance or readability.",
}

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

  -- {
  --   "github/copilot.vim",
  --   event = 'BufReadPre',
  --   init = function()
  --     vim.g.copilot_enabled = 0
  --     vim.g.copilot_no_tab_map = true
  --   end
  -- },

  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = "BufReadPre",
    init = function()
      local utils = require('utils')
      utils.map({ 'n', 'x' }, 'ghs', '<cmd>CopilotChatToggle<cr>')
      utils.map('n', 'ghR', '<cmd>CopilotChatReset<cr>')
      utils.map('n', 'ghS', 'ggvG<cmd>CopilotChatToggle<cr>')
    end,
    build = 'make tiktoken',
    opts = {
      mappings = {
        show_diff = { full_diff = true },
        submit_prompt = { insert = nil },
        reset = { normal = '<c-r>', insert = '<c-r>' },
        close = { normal = 'ghs' },
        show_help = { normal = 'g?' },
        select = { insert = '<tab>' }
      },
      insert_at_end = true,
      auto_insert_mode = false,
      prompts = prompts,
    },
    config = function(_, opts)
      require("CopilotChat").setup(opts)

      -- fzf-lua integration
      local utils = require('utils')
      local actions = require('CopilotChat.actions')
      local integration = require('CopilotChat.integrations.fzflua')
      local win_opts = { winopts = { split = false, height = 0.40, width = 0.50, row = 0.50, col = 0.50 } }
      utils.map({ 'n', 'v' }, 'ghf', function() integration.pick(actions.prompt_actions(), win_opts) end)
    end,
  },
}
