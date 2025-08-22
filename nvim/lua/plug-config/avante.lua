return {
  "yetone/avante.nvim",
  dependencies = {
    "stevearc/dressing.nvim",
    "MunifTanjim/nui.nvim",
  },
  build = "make",
  cmd = { 'AvanteToggle', 'AvanteEdit', 'AvanteAsk' },
  init = function()
    local utils = require("utils")

    utils.map("n", "gaq", function()
      require('avante.diff').conflicts_to_qf_items(function(items)
        vim.print(items)
        if #items > 0 then
          vim.fn.setqflist(items, "r")
          vim.cmd('copen')
        end
      end)
    end)

    utils.map({ "n", "v" }, "gas", '<cmd>AvanteToggle<cr>')
    utils.map("n", "gaR", '<cmd>AvanteClear<cr>')
    utils.map("v", "gae", '<cmd>AvanteEdit<cr>')
    utils.map("v", "gaa", '<cmd>AvanteAsk<cr>')
  end,
  opts = {
    -- debug = true,

    provider = "copilot1",
    -- provider = "openai",

    auto_suggestions_provider = "copilot",
    web_search_engine = { provider = "tavily" },
    disabled_tools = { "python" },

    copilot = {
      model = 'claude-3.7-sonnet-thought',
      disable_tools = false,
      reasoning_effort = 'high',
    },

    openai = {
      endpoint = "https://integrate.api.nvidia.com/v1",

      -- model = "nvidia/llama-3.3-nemotron-super-49b-v1",
      model = "nvdev/nvidia/llama-3.1-nemotron-ultra-253b-v1",
      -- model = "deepseek-ai/deepseek-r1-distill-qwen-32b",
      -- model = "nvidia/nemotron-mini-4b-instruct",
      -- model = 'qwen/qwq-32b',

      -- messages = {{ role = 'system', content = 'detailed thinking off' }},
      reasoning_effort = 'high',

      max_tokens = 4096 * 4,
      temperature = 0.6,
      top_p = 0.7,
      stream = true,
      frequency_penalty = 0,
      presence_penalty = 0,

      disable_tools = true,
    },

    vendors = {
      ["copilot1"] = {
        __inherited_from = "copilot",
        model = "claude-3.7-sonnet",
        display_name = "claude-3.7-sonnet"
      },
      ["copilot2"] = {
        __inherited_from = "copilot",
        model = "claude-3.7-sonnet-thought",
        display_name = "claude-3.7-sonnet-thought",
      },
    },
    dual_boost = {
      enabled = false,
      first_provider = "copilot",
      second_provider = "openai",
      prompt =
      "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
      timeout = 60000,
    },
    rag_service = {
      provider = "openai",
      enabled = false,
      host_mount = os.getenv("HOME") .. '/.cache/nvim/rag/',
      llm_model = "nvdev/nvidia/llama-3.1-nemotron-ultra-253b-v1",
      embed_model = "nvdev/nvidia/nv-embedqa-e5-v5",
      endpoint = "https://integrate.api.nvidia.com/v1", -- The API endpoint for RAG service
    },
    behaviour = {
      auto_suggestions = false, -- Experimental stage
      auto_set_highlight_group = true,
      auto_set_keymaps = false,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
      enable_token_counting = true,
      enable_cursor_planning_mode = false,
      enable_claude_text_editor_tool_mode = true,
    },
    file_selector = {
      provider = 'native',
    },
    mappings = {
      diff = {
        ours = "<m-2>",
        theirs = "<m-3>",
        all_theirs = "<m-a>",
        both = "<m-0>",
        cursor = "cc",
        next = "]x",
        prev = "[x",
      },
      suggestion = {
        accept = "<m-0>",
        next = "<m-]>",
        prev = "<m-[>",
        dismiss = "q",
      },
      jump = {
        next = "]]",
        prev = "[[",
      },
      submit = {
        normal = "<cr>",
        insert = "<c-s>",
      },
      sidebar = {
        apply_all = "A",
        apply_cursor = "a",
        switch_windows = "<tab>",
        reverse_switch_windows = "<s-tab>",
        close = { "q" },
      },
      files = { add_current = "gaC" },
      cancel = {
        normal = { "<c-c>" },
        insert = { "<c-c>" },
      }
    },
    hints = { enabled = false },
    windows = {
      position = "right",
      wrap = true,
      width = 55,
      sidebar_header = {
        enabled = true,
        align = "center",
        rounded = false,
      },
      input = {
        prefix = "> ",
        height = 8,
      },
      edit = {
        border = "single",
        start_insert = false,
      },
      ask = {
        floating = true,
        start_insert = false,
        border = "single",
        focus_on_apply = "ours",
      },
    },
  }
}
