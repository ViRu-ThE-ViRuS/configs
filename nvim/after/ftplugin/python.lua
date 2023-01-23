local terminal = require("terminal")
local utils = require('utils')

-- options
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

-- repl state
local repl_session = {
    job_id = nil,
    bufnr = nil
}

-- launch repl session in terminal, and set it as target_terminalj
utils.add_command("[MISC] REPL: launch ipython", function()
    if repl_session.bufnr ~= nil and vim.api.nvim_buf_get_name(repl_session.bufnr) ~= "" then
        utils.notify(
            string.format(
                "previous repl session closed { job_id %s, bufnr: %s }",
                repl_session.job_id,
                repl_session.bufnr
            ),
            "debug", { title = "[REPL] ipython session" }, true
        )

        vim.api.nvim_buf_delete(repl_session.bufnr, { force = true })
    end

    -- launch repl and set as target terminal
    repl_session = terminal.launch_terminal("ipython3 -i --no-autoindent", false, function()
        terminal.set_target()

        utils.notify(
            string.format(
                "repl session set to { job_id %s, bufnr: %s }",
                utils.workspace_config.run_config.target_terminal.job_id,
                utils.workspace_config.run_config.target_terminal.bufnr
            ),
            "info",
            { title = "[REPL] ipython session" }, true
        )
    end)
end, nil, true)

-- get current cell contents
local function get_current_cell()
    local cell_markers = vim.treesitter.parse_query("python", [[
        ((comment) @cmt (#eq? @cmt "###"))
    ]])

    local bufnr = vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(bufnr, "python", {})
    local tree = parser:parse()[1]

    -- get all markers
    local markers = {}
    for id, node in cell_markers:iter_captures(tree:root(), bufnr, 0, -1) do
        if cell_markers.captures[id] == 'cmt' then
            table.insert(markers, { node:range() })
        end
    end

    -- calculate all cell ranges
    local cells = {}
    for index, range in ipairs(markers) do
        if index ~= 1 then
            table.insert(cells, { markers[index - 1][1] + 1, range[1] })
        else
            table.insert(cells, { 0, range[1] })
        end
    end

    local last_line = vim.api.nvim_buf_line_count(bufnr)
    table.insert(cells, { markers[#markers][1] + 1, last_line })

    -- get contents from relevant cell
    local line = vim.api.nvim_win_get_cursor(0)[1]
    local payload = nil
    for _, range in ipairs(cells) do
        if range[1] <= line and line <= range[2] then
            payload = vim.api.nvim_buf_get_lines(bufnr, range[1], range[2], false)
            break
        end
    end

    -- could not find cell
    if not payload then return nil end

    payload = table.concat(payload, '\n') .. '\n'
    return payload
end

-- run current cell marked by `###`
utils.map("n", "<leader>cc", function()
    local payload = get_current_cell()
    if not payload then return end

    -- NOTE(vir): using clipboard mechanism to handle empty lines
    -- put payload into clipboard register, and paste in repl
    vim.fn.setreg('+', payload, "c")
    terminal.send_to_target('%paste')
end, { buffer = 0 })

-- cell navigation
utils.map('n', ']i', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_next_start("@cell-marker")<CR>zz', { buffer = 0 })
utils.map('n', '[i', '<cmd>lua require"nvim-treesitter.textobjects.move".goto_previous_start("@cell-marker")<CR>zz', { buffer = 0 })
