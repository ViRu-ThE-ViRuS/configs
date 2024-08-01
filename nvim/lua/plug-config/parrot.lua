local API_KEY = os.getenv("NVCF_API_KEY")
if API_KEY ~= nil then
  return {
    url = "ssh://git@gitlab-master.nvidia.com:12051/viraatc/parrot.nvim",
    -- dir = "/home/viraatc/computelab/workspace/parrot.nvim",
    event = "VimEnter",
    init = function()
      local utils = require('utils')

      -- code agents
      utils.map("n", "<leader>ga", "<cmd>PrtVnew<cr>")
      utils.map("v", "<leader>ga", ":'<,'>PrtVnew<cr>")
      utils.map("n", "<leader>gA", "ggVG:'<,'>PrtVnew<cr>")

      -- chat agents
      utils.map("n", "<leader>gs", "<cmd>PrtChatToggle vsplit<cr>")
      utils.map("v", "<leader>gs", ":'<,'>PrtChatToggle vsplit<cr>")
      utils.map("n", "<leader>gS", "ggVG:'<,'>PrtChatPaste vsplit<cr>")

      -- context
      utils.map("n", "<leader>gf", "<cmd>PrtContext vsplit<cr>")
      utils.map("v", "<leader>gf", ":<c-u>'<,'>PrtContext vsplit<cr>")

      utils.add_command("[MISC] PrtChatFinder", "PrtChatFinder", { add_custom = true })
    end,
    opts = {
      providers = {
        openai = {
          api_key = API_KEY,
          endpoint = "https://integrate.api.nvidia.com/v1/chat/completions",
          topic_model = "meta/llama3-70b-instruct"
        }
      },

      chat_confirm_delete = false,
      -- chat_dir = '/home/viraatc/workspace/local/share/nvim/parrot/chats',
      chat_dir = '/tmp/', -- dont save chats

      chat_user_prefix = "[>]:",
      chat_agent_prefix = "[=>]:",
      command_prompt_prefix_template = '[=>] {{agent}}: '
    }
}

else
  return {}
end
