local utils = require("utils")

local M = {}
M.TargetTerminal = nil
M.TargetCommand = ""

M.SetTargetTerminal = function()
    if vim.b.terminal_job_id ~= nil then
        M.TargetTerminal = {
            ["job_id"] = vim.b.terminal_job_id,
            ["buf_nr"] = vim.api.nvim_win_get_buf(0)
        }

        print(
            string.format(
                "TargetTerminal set to: { job_id: %s, buf_nr: %s }",
                M.TargetTerminal.job_id,
                M.TargetTerminal.buf_nr
            )
        )
    else
        print("TargetTerminal not set")
    end
end

M.ToggleTarget = function(open)
    if M.TargetTerminal == nil then
        print("TargetTerminal not set")
        return
    end

    -- if visible, close
    local target_winid = vim.fn.bufwinid(M.TargetTerminal.buf_nr)
    if target_winid ~= -1 and #vim.api.nvim_list_wins() ~= 1 then
        if not open then
            vim.api.nvim_win_close(target_winid, false)
        end
        return
    end

    -- else split
    local split_dir = "v"
    if utils.is_htruncated(utils.truncation_limit_s) then
        split_dir = ""
    end

    vim.cmd(split_dir .. "split #" .. M.TargetTerminal.buf_nr)
end

M.SendToTarget = function(payload, repeat_last)
    if M.TargetTerminal ~= nil then
        if vim.fn.bufname(M.TargetTerminal.buf_nr) ~= "" then
            if repeat_last then
                vim.cmd("call chansend(" .. M.TargetTerminal.job_id .. ', "\x1b\x5b\x41\\<cr>")')
            else
                vim.api.nvim_chan_send(M.TargetTerminal.job_id, payload .. "\n")
            end
        else
            M.TargetTerminal = nil
            print("TargetTerminal does not exist, resetting state")
        end
    else
        print("TargetTerminal not set")
    end

    if not repeat_last then
        M.ToggleTarget(not repeat_last)
    end
end

M.SetTargetCommand = function()
    M.TargetCommand = vim.fn.input("TargetCommand: ", "")
end

M.QueryState = function()
    print(vim.inspect(M))
end

M.RunTargetCommand = function()
    if M.TargetCommand ~= "" then
        M.SendToTarget(M.TargetCommand, false)
    else
        print("TargetCommand not set")
    end
end

M.SetTarget = function()
    if vim.b.terminal_job_id ~= nil then
        M.SetTargetTerminal()
    else
        M.SetTargetCommand()
    end
end

M.RunPreviousCommand = function()
    M.SendToTarget(nil, true)
end

utils.map("n", "<leader>cA", '<cmd>lua require("terminal").RunTargetCommand()<cr>')
utils.map("n", "<leader>ca", '<cmd>lua require("terminal").RunPreviousCommand()<cr>')
utils.map("n", "<leader>cf", '<cmd>lua require("terminal").SetTarget()<cr>')
utils.map("n", "<leader>cs", '<cmd>lua require("terminal").ToggleTarget(false)<cr>')

return M
