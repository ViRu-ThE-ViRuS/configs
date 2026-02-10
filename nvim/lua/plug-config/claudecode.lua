-- Claude Code IDE integration with custom terminal management
return {
  "coder/claudecode.nvim",
  lazy = false,
  config = function()
    local misc = require('lib/misc')
    local utils = require('utils')
    local truncation = session.config.truncation

    -- Setup claudecode.nvim with no terminal (we manage it)
    require("claudecode").setup({
      terminal = { provider = "none" },
      auto_start = true,
      diff_opts = {
        auto_close_on_accept = true,
        vertical_split = true,
        open_in_current_tab = false,
        keep_terminal_focus = true,
      },
    })

    -- Setup diff buffer keymaps via autocmd
    vim.api.nvim_create_autocmd('BufEnter', {
      group = vim.api.nvim_create_augroup('ClaudeCodeDiffKeymaps', { clear = true }),
      callback = function(args)
        local buf = args.buf
        if vim.b[buf].claudecode_diff_tab_name or
            vim.b[buf].claudecode_diff_new_win or
            vim.b[buf].claudecode_diff_target_win then
          utils.map('n', '<m1>', '<cmd>ClaudeCodeDiffAccept<cr>',
            { buffer = buf, desc = 'Accept Claude diff' })
          utils.map('n', '<m2>', '<cmd>ClaudeCodeDiffDeny<cr>',
            { buffer = buf, desc = 'Reject Claude diff' })
        end
      end,
    })

    local claude_bufnr = nil
    local claude_job_id = nil
    local palette = session.state.palette

    local function get_git_root()
      local result = vim.fn.systemlist('git rev-parse --show-toplevel')[1]
      if vim.v.shell_error == 0 and result then
        return result
      end
      return vim.fn.getcwd()
    end

    local function get_claude_window()
      if not claude_bufnr or not vim.api.nvim_buf_is_valid(claude_bufnr) then
        return nil
      end
      for _, winid in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(winid) == claude_bufnr then
          return winid
        end
      end
      return nil
    end

    local function launch_claude()
      local claudecode = require("claudecode")
      local state = claudecode.state

      -- Start server if not running
      if not state.port then
        claudecode.start()
        vim.wait(100, function()
          return claudecode.state.port ~= nil
        end, 10)
      end

      -- Use same split logic as your terminal library
      local split_cmd = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "sp") or "vsp"
      vim.cmd(split_cmd)

      claude_bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = claude_bufnr })
      vim.api.nvim_set_option_value('buflisted', false, { buf = claude_bufnr })
      pcall(vim.api.nvim_buf_set_name, claude_bufnr, '[Claude]')
      vim.api.nvim_win_set_buf(0, claude_bufnr)

      -- Build environment for IDE mode
      local env = {}
      if claudecode.state.port then
        env.CLAUDE_CODE_SSE_PORT = tostring(claudecode.state.port)
        env.ENABLE_IDE_INTEGRATION = "true"
      end

      local job_id = vim.fn.termopen('claude', {
        env = env,
        cwd = get_git_root(),
        on_exit = function()
          -- Deregister from palette on exit
          if claude_job_id then
            -- Find and clear index if registered
            for index, id in pairs(palette.terminals.indices) do
              if id == claude_job_id then
                palette.terminals.indices[index] = {}
                break
              end
            end
            palette.terminals.term_states[claude_job_id] = nil
          end
          claude_bufnr = nil
          claude_job_id = nil
        end,
      })

      -- Register with terminal palette
      claude_job_id = job_id
      palette.terminals.term_states[job_id] = {
        job_id = job_id,
        bufnr = claude_bufnr,
      }

      -- Set as primary if no primary exists
      local primary_id = palette.terminals.indices[1]
      if not primary_id or type(primary_id) == 'table' then
        palette.terminals.indices[1] = job_id
      end

    end

    local function toggle_claude()
      local win = get_claude_window()
      if win then
        if vim.api.nvim_get_current_win() == win then
          vim.api.nvim_win_close(win, false)
        else
          vim.api.nvim_set_current_win(win)
        end
      else
        if claude_bufnr and vim.api.nvim_buf_is_valid(claude_bufnr) then
          -- Reopen existing buffer with same split logic
          local split_cmd = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "sp") or "vsp"
          vim.cmd(string.format('%s #%d', split_cmd, claude_bufnr))
        else
          launch_claude()
        end
      end
    end

    local function spawn_claude_session()
      local claudecode = require("claudecode")

      -- Start server if not running
      if not claudecode.state.port then
        claudecode.start()
        vim.wait(100, function()
          return claudecode.state.port ~= nil
        end, 10)
      end

      -- Use same split logic as terminal library
      local split_cmd = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "sp") or "vsp"
      vim.cmd(split_cmd)

      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_set_option_value('bufhidden', 'hide', { buf = bufnr })
      vim.api.nvim_set_option_value('buflisted', false, { buf = bufnr })
      local session_num = vim.tbl_count(palette.terminals.term_states) + 1
      pcall(vim.api.nvim_buf_set_name, bufnr, '[Claude ' .. session_num .. ']')
      vim.api.nvim_win_set_buf(0, bufnr)

      -- Build environment for IDE mode
      local env = {}
      if claudecode.state.port then
        env.CLAUDE_CODE_SSE_PORT = tostring(claudecode.state.port)
        env.ENABLE_IDE_INTEGRATION = "true"
      end

      local session_job_id = nil
      session_job_id = vim.fn.termopen('claude', {
        env = env,
        cwd = get_git_root(),
        on_exit = function()
          -- Deregister from palette on exit
          if session_job_id then
            for index, id in pairs(palette.terminals.indices) do
              if id == session_job_id then
                palette.terminals.indices[index] = {}
                break
              end
            end
            palette.terminals.term_states[session_job_id] = nil
          end
        end,
      })

      -- Register with terminal palette
      palette.terminals.term_states[session_job_id] = {
        job_id = session_job_id,
        bufnr = bufnr,
      }

      -- Set as primary if no primary exists
      local primary_id = palette.terminals.indices[1]
      if not primary_id or type(primary_id) == 'table' then
        palette.terminals.indices[1] = session_job_id
      end

      vim.cmd('startinsert')
    end

    -- Commands
    vim.api.nvim_create_user_command('ClaudeCode', toggle_claude, {})
    utils.add_command('[CLAUDE] New Session', spawn_claude_session, { add_custom = true })

    -- Keymaps (no terminal mode map - you can type freely)
    utils.map('n', "gas", toggle_claude, { desc = 'Claude Code' })
    local function focus_claude()
      local win = get_claude_window()
      if win then
        vim.api.nvim_set_current_win(win)
        vim.cmd('startinsert')
      elseif claude_bufnr and vim.api.nvim_buf_is_valid(claude_bufnr) then
        local split_cmd = (misc.is_htruncated(truncation.truncation_limit_s_terminal) and "sp") or "vsp"
        vim.cmd(string.format('%s #%d', split_cmd, claude_bufnr))
        vim.cmd('startinsert')
      else
        launch_claude()
      end
    end

    utils.map('v', "ga", function()
      vim.cmd('ClaudeCodeSend')
      focus_claude()
    end, { desc = 'Send to Claude' })
    utils.map('n', "gA", function()
      vim.cmd('ClaudeCodeAdd %')
      focus_claude()
    end, { desc = 'Add buffer to Claude' })

    -- NvimTree/neo-tree/oil specific keymap
    vim.api.nvim_create_autocmd('FileType', {
      group = vim.api.nvim_create_augroup('ClaudeCodeTreeKeymaps', { clear = true }),
      pattern = { 'NvimTree', 'neo-tree', 'oil', 'minifiles', 'netrw' },
      callback = function(args)
        utils.map('n', 'gA', '<cmd>ClaudeCodeTreeAdd<cr>',
          { buffer = args.buf, desc = 'Add file to Claude' })
        utils.map('n', 'gas', '<cmd>ClaudeCodeTreeAdd<cr>',
          { buffer = args.buf, desc = 'Add file to Claude' })
      end,
    })

    -- Auto-reload files when changed externally (e.g., by Claude Code)
    vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
      pattern = "*",
      callback = function()
        if vim.fn.getcmdwintype() == "" then
          vim.cmd("checktime")
        end
      end,
    })
  end,
}
