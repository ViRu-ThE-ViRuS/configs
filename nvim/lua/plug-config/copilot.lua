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
      prompts = {
        Pythonize = {
          prompt =
          "/COPILOT_GENERATE\n\nYou are an expert Python developer. Your task is to convert the given code to Python using the latest practices. Optimize for minimal and easy-to-understand code. Prefer built-in libraries, but use third-party libraries if they significantly improve readability or performance."
        }
      }
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
