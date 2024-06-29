return {
  url = "ssh://git@gitlab-master.nvidia.com:12051/asubramaniam/gp.nvim",
  init = function()

  end,
  event = 'BufWinEnter',
  opts = {
    api_key = os.getenv('NVCF_API_KEY'),
    cmd_prefix = "Gp",

    chat_user_prefix = "[>]:",
    chat_assistant_prefix = { "[ai]:", "[{{agent}}]" },
    chat_topic_gen_prompt = "Summarize the topic of our conversation above"
        .. " in two or three words. Respond only with those words.",
    chat_confirm_delete = true,
    chat_conceal_model_params = true,

    chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
    chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },
    chat_shortcut_stop = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>s" },
    chat_shortcut_new = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>c" },

    chat_finder_pattern = "topic ",
    chat_free_cursor = false,
    toggle_target = "vsplit",

    style_chat_finder_border = "rounded",
    style_chat_finder_margin_bottom = 8,
    style_chat_finder_margin_left = 1,
    style_chat_finder_margin_right = 2,
    style_chat_finder_margin_top = 2,
    style_chat_finder_preview_ratio = 0.5,

    command_prompt_prefix_template = "[ai] {{agent}} > ",
    command_auto_select_response = true,

    -- templates
    template_selection = "I have the following from {{filename}}:"
        .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}",
    template_rewrite = "I have the following from {{filename}}:"
        .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
        .. "\n\nRespond exclusively with the snippet that should replace the selection above.",
    template_append = "I have the following from {{filename}}:"
        .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
        .. "\n\nRespond exclusively with the snippet that should be appended after the selection above.",
    template_prepend = "I have the following from {{filename}}:"
        .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
        .. "\n\nRespond exclusively with the snippet that should be prepended before the selection above.",
    template_command = "{{command}}",

    image_prompt_prefix_template = "[ai] {{agent}} > ",
    image_prompt_save = "[ai] *save image* > ",
    image_dir = (os.getenv("TMPDIR") or os.getenv("TEMP") or "/tmp") .. "/gp_images",

    hooks = {
      InspectPlugin = function(plugin, params)
        local bufnr = vim.api.nvim_create_buf(false, true)
        local copy = vim.deepcopy(plugin)
        local key = copy.config.api_key
        copy.config.api_key = key:sub(1, 3) ..
            string.rep("*", #key - 6) .. key:sub(-3)
        local plugin_info = string.format("Plugin structure:\n%s",
          vim.inspect(copy))
        local params_info = string.format("Command params:\n%s",
          vim.inspect(params))
        local lines = vim.split(plugin_info .. "\n" .. params_info, "\n")
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.api.nvim_win_set_buf(0, bufnr)
      end,

      -- GpImplement rewrites the provided selection/range based on comments in it
      Implement = function(gp, params)
        local template = "Having following from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please rewrite this according to the contained instructions."
            .. "\n\nRespond exclusively with the snippet that should replace the selection above."

        local agent = gp.get_command_agent()
        gp.info("Implementing selection with agent: " .. agent.name)

        gp.Prompt(
          params,
          gp.Target.rewrite,
          nil, -- command will run directly without any prompting for user input
          agent.model,
          template,
          agent.system_prompt
        )
      end,

      -- your own functions can go here, see README for more examples like
      -- :GpExplain, :GpUnitTests.., :GpTranslator etc.

      -- -- example of making :%GpChatNew a dedicated command which
      -- -- opens new chat with the entire current buffer as a context
      -- BufferChatNew = function(gp, _)
      -- 	-- call GpChatNew command in range mode on whole buffer
      -- 	vim.api.nvim_command("%" .. gp.config.cmd_prefix .. "ChatNew")
      -- end,

      -- Translator = function(gp, params)
      -- 	local agent = gp.get_command_agent()
      -- 	local chat_system_prompt = "You are a Translator, please translate between English and Chinese."
      -- 	gp.cmd.ChatNew(params, agent.model, chat_system_prompt)
      -- end,

      UnitTests = function(gp, params)
        local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by writing table driven unit tests for the code above."
        local agent = gp.get_command_agent()
        gp.Prompt(params, gp.Target.enew, nil, agent.model, template,
          agent.system_prompt)
      end,

      Explain = function(gp, params)
        local template = "I have the following code from {{filename}}:\n\n"
            .. "```{{filetype}}\n{{selection}}\n```\n\n"
            .. "Please respond by explaining the code above."
        local agent = gp.get_chat_agent()
        gp.Prompt(params, gp.Target.popup, nil, agent.model, template,
          agent.system_prompt)
      end,
    },
  }
}
