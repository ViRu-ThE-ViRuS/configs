return {
  "yetone/avante.nvim",
  dependencies = {
    "stevearc/dressing.nvim",
    "MunifTanjim/nui.nvim",
  },
  build = "make",
  cmd = { 'AvanteToggle', 'AvanteEdit' },
  init = function()
    local utils = require("utils")
    utils.map({ "n", "v" }, "gas", '<cmd>AvanteToggle<cr>')
    utils.map("v", "gae", '<cmd>AvanteEdit<cr>')
    utils.map("n", "gaR", '<cmd>AvanteClear<cr>')

    utils.map("n", "gaq", function()
      require('avante.diff').conflicts_to_qf_items(function(items)
        vim.print(items)
        if #items > 0 then
          vim.fn.setqflist(items, "r")
          vim.cmd('copen')
        end
      end)
    end)
  end,
  opts = {
    provider = "copilot",
    -- provider = "openai",
    openai = {
      endpoint = "https://integrate.api.nvidia.com/v1",
      -- model = "nvdev/nvidia/llama-3.3-nemotron-super-49b-v1",
      model = "deepseek-ai/deepseek-r1-distill-qwen-32b",
      temperature=0.6,
      top_p=0.7,
      max_tokens=4096,
      stream=true,
      disable_tools = true,
      reasoning_effort='high'
    },
    auto_suggestions_provider = "copilot",
    dual_boost = {
      enabled = false,
      first_provider = "copilot",
      second_provider = "openai",
      prompt = "Based on the two reference outputs below, generate a response that incorporates elements from both but reflects your own judgment and unique perspective. Do not provide any explanation, just give the response directly. Reference Output 1: [{{provider1_output}}], Reference Output 2: [{{provider2_output}}]",
      timeout = 60000,
    },
    behaviour = {
      auto_suggestions = false,
      auto_set_highlight_group = true,
      auto_set_keymaps = false,
      auto_apply_diff_after_generation = false,
      support_paste_from_clipboard = false,
      minimize_diff = true,
      enable_token_counting = true,
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
      files = { add_current = "gaC" }
    },
    hints = { enabled = false },
    windows = {
      position = "right",
      wrap = false,
      width = 35,
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
