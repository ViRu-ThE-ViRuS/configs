local API_KEY = os.getenv("NVCF_API_KEY")
if API_KEY ~= nil then
  return {
    url = "ssh://git@gitlab-master.nvidia.com:12051/viraatc/parrot.nvim",
    -- dir = "/home/viraatc/computelab/workspace/parrot.nvim",
    event = "VimEnter",
    init = function()
      local utils = require('utils')

      utils.map("n", "<leader>ia", "<cmd>PrtVnew<cr>")
      utils.map("n", "<leader>if", "<cmd>PrtPopup<cr>")
      utils.map("n", "<leader>iF", "<cmd>PrtChatFinder<cr>")

      utils.map("n", "<leader>is", "<cmd>PrtChatToggle vsplit<cr>")
      utils.map("v", "<leader>is", ":<c-u>'<,'>PrtChatToggle vsplit<cr>")

      utils.map("n", "<leader>iS", "<cmd>PrtContext vsplit<cr>")
      utils.map("v", "<leader>iS", ":<c-u>'<,'>PrtContext vsplit<cr>")
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
      chat_dir = os.getenv("HOME") .. '/.local/share/nvim/parrot/chats',

      chat_user_prefix = "[>]:",
      chat_agent_prefix = "[=>]:",
      command_prompt_prefix_template = '[=>] {{agent}}: '
    }
}

else
  return {}
end
