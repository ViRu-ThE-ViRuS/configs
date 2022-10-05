local terminal = require("terminal")
local utils = require('utils')

-- options
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

local repl_session = {
    job_id = nil,
    bufnr = nil
}

utils.add_command("[REPL] launch ipython", function()
    if repl_session.bufnr ~= nil and vim.fn.bufname(repl_session.bufnr) ~= "" then
        utils.notify(
            string.format(
                "previous repl session closed { job_id %s, bufnr: %s }",
                repl_session.job_id,
                repl_session.bufnr
            ),
            "debug", { title = "[repl] ipython session" }, true
        )

        vim.api.nvim_buf_delete(repl_session.bufnr, { force = true })
    end

    terminal.launch_terminal("ipython3 -i --no-autoindent", false, function()
        terminal.set_target()

        repl_session = {
            job_id = utils.run_config.target_terminal.job_id,
            bufnr = utils.run_config.target_terminal.bufnr
        }

        utils.notify(
            string.format(
                "repl session set to { job_id %s, bufnr: %s }",
                repl_session.job_id,
                repl_session.bufnr
            ),
            "debug", { title = "[repl] ipython session" }, true
        )
    end)
end)

