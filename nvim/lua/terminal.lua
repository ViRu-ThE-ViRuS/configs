local utils = require("utils")
local run_config = utils.run_config
local core = require('lib/core')

-- scroll target to bottom
local function target_scroll_to_end()
    if run_config.target_terminal == nil then return end
    local win_id = vim.fn.bufwinid(run_config.target_terminal.bufnr)

    if win_id == -1 then return end
    vim.fn.win_execute(win_id, "normal! G")
end

-- toggle target_terminal
local function toggle_target(open)
    if run_config.target_terminal == nil then
        utils.notify('[terminal] target not set', 'warn', { render = 'minimal' }, true)
        return
    end

    local target_winid = vim.fn.bufwinid(run_config.target_terminal.bufnr)

    if target_winid ~= -1 and #vim.api.nvim_list_wins() ~= 1 then
        -- hide target
        if not open then
            if not pcall(vim.api.nvim_win_close, target_winid, false) then
                utils.notify('[terminal] target exited, resetting state', 'debug', { render = 'minimal' }, true)
                run_config.target_terminal = nil
                return
            end
        end
    else
        local split_dir = "v"
        if utils.is_htruncated(utils.truncation_limit_s_terminal) then
            split_dir = ""
        end

        -- open in split
        if not pcall(vim.cmd, split_dir .. 'split #' .. run_config.target_terminal.bufnr) then
            utils.notify('[terminal] target exited, resetting state', 'debug', { render = 'minimal' }, true)
            run_config.target_terminal = nil
            return
        end
    end
end

-- send payload to target_terminal
local function send_to_target(payload, repeat_last)
    if run_config.target_terminal ~= nil then
        if vim.fn.bufname(run_config.target_terminal.bufnr) ~= "" then
            if repeat_last then
                if pcall(vim.cmd, "call chansend(" .. run_config.target_terminal.job_id .. ', "\x1b\x5b\x41\\<cr>")') then
                    toggle_target(true)
                    return
                end
            else
                if pcall(vim.api.nvim_chan_send, run_config.target_terminal.job_id, payload .. '\n') then
                    toggle_target(true)
                    return
                end
            end

            utils.notify('[terminal] target exited, resetting state', 'debug', { render = 'minimal' }, true)
            run_config.target_terminal = nil

            return
        else
            utils.notify('[terminal] target does not exist, resetting state', 'debug', { render = 'minimal' }, true)
            run_config.target_terminal = nil
        end
    else
        utils.notify('[terminal] target not set', 'warn', { render = 'minimal' }, true)
    end
end

-- set target_terminal to this one
local function set_target_terminal()
    if vim.b.terminal_job_id ~= nil then
        run_config.target_terminal = {
            job_id = vim.b.terminal_job_id,
            bufnr = vim.api.nvim_win_get_buf(0),
        }

        utils.notify(
            string.format(
                "target_terminal set to: { job_id: %s, bufnr: %s }",
                run_config.target_terminal.job_id,
                run_config.target_terminal.bufnr
            ),
            "info",
            { render = "minimal" },
            true
        )
    else
        utils.notify('[terminal] target not set', 'warn', { render = 'minimal' }, true)
    end
end

-- setup target_command
local function set_target_command()
    run_config.target_command = vim.fn.input('[terminal] target_command: ', '', 'shellcmd')
end

-- set target_terminal/target_command
local function set_target()
    if vim.b.terminal_job_id ~= nil then
        set_target_terminal()
    else
        set_target_command()
    end
end

-- run target_command
local function run_target_command()
    if run_config.target_command ~= "" then
        send_to_target(run_config.target_command, false)
        target_scroll_to_end()
    else
        utils.notify('[terminal] target not set', 'warn', { render = 'minimal' }, true)
    end
end

-- run previous command in target_terminal
local function run_previous_command()
    send_to_target(nil, true)
    target_scroll_to_end()
end

-- send visually selected lines to target_terminal
local function run_selection(line_mode)
    local payload = nil

    if line_mode then
        local line = vim.api.nvim_win_get_cursor(0)[1]
        payload = vim.trim(vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1])
    else
        local l1 = vim.api.nvim_buf_get_mark(0, "<")[1]
        local l2 = vim.api.nvim_buf_get_mark(0, ">")[1]
        if l1 > l2 then l1, l2 = l2, l1 end

        local lines = vim.fn.getline(l1, l2)
        payload = table.concat(core.filter(lines, function(_, value) return vim.trim(value) ~= '' end), '\n')
        payload = payload .. '\n'
    end

    send_to_target(payload)
    target_scroll_to_end()
end

-- launch a terminal with the command in a split
local function launch_terminal(command, background, callback)
    vim.cmd('vsp term://' .. vim.o.shell)
    local bufnr = vim.api.nvim_get_current_buf()

    vim.defer_fn(function()
        if pcall(vim.api.nvim_chan_send, vim.b.terminal_job_id, command .. "\n") then
            utils.notify(command, 'info', { title = '[terminal] launched command' }, true)
        end

        if callback then callback() end

        if background then vim.cmd [[ :q ]]
        else vim.cmd [[ wincmd p ]] end
    end, 250)

    return bufnr
end

return {
    -- run-config
    toggle_target = toggle_target,
    set_target = set_target,
    run_target_command = run_target_command,
    run_previous_command = run_previous_command,
    run_selection = run_selection,

    -- general
    launch_terminal = launch_terminal,
}
