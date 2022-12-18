local terminal = require("terminal")
local utils = require('utils')
local core = require('lib/core')

-- options
vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4

local repl_session = {
    job_id = nil,
    bufnr = nil
}

utils.add_command("[MISC] REPL: launch ipython", function()
    if repl_session.bufnr ~= nil and vim.api.nvim_buf_get_name(repl_session.bufnr) ~= "" then
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
end, nil, true)

-- TODO(vir): improve this
-- NOTE(vir): has a lot of kinks rn
--  - handle new lines
--  - consider %paste method instead
local function get_current_cell()
    local cell_markers = vim.treesitter.parse_query("python", [[
        ((comment) @cmt (#eq? @cmt "###"))
    ]])

    local bufnr = vim.api.nvim_get_current_buf()
    local parser = vim.treesitter.get_parser(bufnr, "python", {})
    local tree = parser:parse()[1]

    local markers = {}
    for id, node in cell_markers:iter_captures(tree:root(), bufnr, 0, -1) do
        local name = cell_markers.captures[id]
        if name == 'cmt' then table.insert(markers, { node:range() }) end
    end

    local cells = {}
    for index, range in ipairs(markers) do
        if index ~= 1 then table.insert(cells, { markers[index-1][1] + 1, range[1] }) end
    end

    local last_line = vim.api.nvim_buf_line_count(bufnr)
    table.insert(cells, {markers[#markers][1] + 1, last_line})

    local line = vim.api.nvim_win_get_cursor(0)[1]
    local payload = nil
    for _, range in ipairs(cells) do
        if range[1] <=line and line <= range[2] then
            payload = vim.api.nvim_buf_get_lines(bufnr, range[1], range[2], false)
            break
        end
    end

    -- could not find cell
    if not payload then return nil end

    payload = table.concat(core.filter(payload, function(_, value) return vim.trim(value) ~= '' end), '\n')
    payload = payload .. '\n'
    return payload
end

utils.map("n", "<leader>cc", function()
    local payload = get_current_cell()
    if not payload then return end

    terminal.send_to_target(payload)
    terminal.target_scroll_to_end()
end, { buffer = 0 })
