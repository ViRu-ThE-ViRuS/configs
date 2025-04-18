-- inspired by https://github.com/jellydn/lazy-nvim-ide/blob/main/lua/plugins/extras/copilot-chat-v2.lua
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
  Visualize =
  {
    context = { "selection" },
    prompt =
    "Visualize the selected code using ascii diagrams to depict the control flow. Include as much detail as possible, the goal is to depict all paths and what choices lead to them.",
  }
}

return {
  {
    "Davidyz/VectorCode",
    cmd = "VectorCode",
  },

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
      utils.map('n', 'ghc', '<cmd>CopilotChatStop<cr>')
    end,
    build = 'make tiktoken',
    opts = {
      model = 'claude-3.7-sonnet-thought',
      -- model = 'nvidia/llama-3.1-nemotron-ultra-253b-v1',
      mappings = {
        show_diff = { full_diff = true },
        submit_prompt = { insert = nil },
        reset = { normal = '<c-r>', insert = '<c-r>' },
        close = { normal = 'ghs' },
        show_help = { normal = 'g?' },
        select = { insert = '<tab>' },
        complete = { insert = '<c-p>' }
      },
      insert_at_end = false,
      auto_insert_mode = false,
      prompts = prompts,
    },
    config = function(_, opts)
      local vectorcode_ctx = require('vectorcode.integrations.copilotchat').make_context_provider({
        prompt_header = "Here are relevant files from the repository:",
        prompt_footer = "\nConsider this context when answering:",
        skip_empty = true,
      })

      opts.contexts = vim.tbl_extend("force", opts.contexts or {}, { vectorcode = vectorcode_ctx })
      opts.prompts = vim.tbl_extend("force", opts.prompts or {},
        {
          DeepExplain = {
            prompt = "Please explain how the following code works.",
            context = { "selection", "vectorcode" },
          },
        })

      opts.providers = {
        nvcf = {
          prepare_input = require('CopilotChat.config.providers').copilot.prepare_input,
          prepare_output = require('CopilotChat.config.providers').copilot.prepare_output,

          get_headers = function()
            local api_key = assert(os.getenv('NVCF_API_KEY'), 'NVCF_API_KEY env not set')
            return {
              Authorization = 'Bearer ' .. api_key,
              ['Content-Type'] = 'application/json',
            }
          end,

          get_models = function(headers)
            local endpoint = "https://integrate.api.nvidia.com/v1"
            local response, err = require('CopilotChat.utils').curl_get(endpoint .. '/models', {
              headers = headers,
              json_response = true,
            })

            if err then
              error(err)
            end

            return vim.iter(response.body.data)
                :map(function(model)
                  return {
                    id = model.id,
                    name = model.name,
                  }
                end)
                :totable()
          end,

          embed = function(inputs, headers)
            local endpoint = "https://integrate.api.nvidia.com/v1"
            local response, err = require('CopilotChat.utils').curl_post(endpoint .. '/embeddings', {
              headers = headers,
              json_request = true,
              json_response = true,
              body = {
                input = inputs,
                model = 'nvdev/nvidia/nv-embedqa-e5-v5',
              },
            })

            if err then
              error(err)
            end

            return response.body.data
          end,

          get_url = function()
            local endpoint = "https://integrate.api.nvidia.com/v1"
            return endpoint .. '/chat/completions'
          end,
        },
      }

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
