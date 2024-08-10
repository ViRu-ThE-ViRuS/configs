local API_KEY = os.getenv("NVCF_API_KEY")
if API_KEY ~= nil then
  return {
    url = "ssh://git@gitlab-master.nvidia.com:12051/viraatc/parrot.nvim",
    -- dir = "/home/viraatc/computelab/workspace/parrot.nvim",
    event = "BufReadPre",
    init = function()
      local utils = require('utils')

      -- code agents
      utils.map("n", "gaa", "<cmd>PrtVnew<cr>")
      utils.map("v", "gaa", ":'<,'>PrtVnew<cr>")
      utils.map("n", "gaA", "ggVG:'<,'>PrtVnew<cr>")

      -- chat agents
      utils.map("n", "gas", "<cmd>PrtChatToggle vsplit<cr>")
      utils.map("v", "gas", ":'<,'>PrtChatToggle vsplit<cr>")
      utils.map("n", "gaS", "ggVG:'<,'>PrtChatPaste vsplit<cr>")

      -- context
      utils.map("n", "gac", "<cmd>PrtContext vsplit<cr>")
      utils.map("v", "gac", ":<c-u>'<,'>PrtContext vsplit<cr>")

      utils.add_command("[MISC] PrtChatFinder", "PrtChatFinder", { add_custom = true })
    end,
    opts = {
      providers = {
        nvidia = {
          api_key = API_KEY,
          endpoint = "https://integrate.api.nvidia.com/v1/chat/completions",
          topic = { model = "meta/llama3-70b-instruct" },
        },
      },

      chat_confirm_delete = false,
      chat_dir = '/tmp/nvim_prt_chats/', -- dont save chats

      chat_user_prefix = "[>]:",
      llm_prefix = "[=>]:",
      command_prompt_prefix_template = '[>] {{llm}}: '
    }
}

else
  return {}
end
