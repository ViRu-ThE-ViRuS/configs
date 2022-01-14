local utils = require("utils")
local state = utils.run_config

-- toggle target_terminal
local function toggle_target(open)
    if state.target_terminal == nil then
        print("target_terminal not set")
        return
    end

    -- if visible, close
    local target_winid = vim.fn.bufwinid(state.target_terminal.buf_nr)
    if target_winid ~= -1 and #vim.api.nvim_list_wins() ~= 1 then
        if not open then
            -- vim.api.nvim_win_close(target_winid, false)
            if not pcall(vim.api.nvim_win_close, target_winid, false) then
                state.target_terminal = nil
                print("target_terminal exited, resetting state")
            end
        end
        return
    end

    -- else split
    local split_dir = "v"
    if utils.is_htruncated(utils.truncation_limit_s_terminal) then
        split_dir = ""
    end

    -- vim.cmd(split_dir .. "split #" .. state.target_terminal.buf_nr)
    if not pcall(vim.cmd, split_dir .. "split #" .. state.target_terminal.buf_nr) then
        state.target_terminal = nil
        print("target_terminal exited, resetting state")
    end
end

-- send payload to target_terminal
local function send_to_target(payload, repeat_last)
    if state.target_terminal ~= nil then
        if vim.fn.bufname(state.target_terminal.buf_nr) ~= "" then
            if repeat_last then
                -- vim.cmd("call chansend(" .. state.target_terminal.job_id .. ', "\x1b\x5b\x41\\<cr>")')
                if pcall(vim.cmd, "call chansend(" .. state.target_terminal.job_id .. ', "\x1b\x5b\x41\\<cr>")') then
                    toggle_target(true)
                    return
                end
            else
                -- vim.api.nvim_chan_send(state.target_terminal.job_id, payload .. "\n")
                if pcall(vim.api.nvim_chan_send, state.target_terminal.job_id, payload .. "\n") then
                    toggle_target(true)
                    return
                end
            end

            state.target_terminal = nil
            print("target_terminal exited, resetting state")
            return
        else
            state.target_terminal = nil
            print("target_terminal does not exist, resetting state")
        end
    else
        print("target_terminal not set")
    end
end

-- set target_terminal to this one
local function set_target_terminal()
    if vim.b.terminal_job_id ~= nil then
        state.target_terminal = {
            ["job_id"] = vim.b.terminal_job_id,
            ["buf_nr"] = vim.api.nvim_win_get_buf(0)
        }

        print(
            string.format(
                "target_terminal set to: { job_id: %s, buf_nr: %s }",
                state.target_terminal.job_id,
                state.target_terminal.buf_nr
            )
        )
    else
        print("target_terminal not set")
    end
end

-- setup target_command
local function set_target_command()
    state.target_command = vim.fn.input("target_command: ", "")
end

-- query the current state, utility
local function query_state() print(vim.inspect(state)) end

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
    if state.target_command ~= "" then
        send_to_target(state.target_command, false)
    else
        print("target_command not set")
    end
end

-- run previous command in target_terminal
local function run_previous_command()
    send_to_target(nil, true)
end

return {
    toggle_target = toggle_target,
    query_state = query_state,
    set_target = set_target,
    run_target_command = run_target_command,
    run_previous_command = run_previous_command
}
