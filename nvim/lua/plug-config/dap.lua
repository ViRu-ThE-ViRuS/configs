local dap = require('dap')
local dapui = require('dapui')
local utils = require('utils')
local core = require('lib/core')

-- servers launched internally in neovim
local internal_servers = {codelldb = 'codelldb server'}

-- adapters
dap.adapters.python = {
    type = 'executable',
    command = 'python3',
    args = {'-m', 'debugpy.adapter'}
}
dap.adapters.codelldb = function(callback, _)
    require('terminal').launch_terminal('codelldb', true, function()
        vim.api.nvim_buf_set_name(0, internal_servers.codelldb)
        vim.defer_fn(function()
            callback({type = 'server', host = '127.0.0.1', port = 13000})
        end, 1500)
    end)
end

-- language configurations
dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        program = '${file}',
        terminal = 'integrated',
        console = 'integratedTerminal',
        pythonPath = core.get_python()
    }
}

dap.configurations.c = {
    {
        type = "codelldb",
        request = "launch",
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        stopOnEntry = false,
        program = function()
            return vim.fn.input('executable: ', vim.fn.getcwd() .. '/', 'file')
        end
    }
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.cpp

-- repl setup
dap.repl.commands = vim.tbl_extend('force', dap.repl.commands, {
    exit = {'q', 'exit'},
    custom_commands = {
        ['.run_to_cursor'] = dap.run_to_cursor,
        ['.restart'] = dap.run_last
    }
})

-- dapui setup
dapui.setup({
    icons = {expanded = "-", collapsed = "$"},
    mappings = {
        expand = "<CR>",
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r",
        toggle = 't'
    },
    sidebar = {
        elements = {
            {id = "scopes", size = 0.5}, {id = "breakpoints", size = 0.25},
            {id = "stacks", size = 0.25}
        },
        size = 40,
        position = "right"
    },
    tray = {elements = {"repl", "watches"}, size = 10, position = "bottom"},
    floating = {border = "rounded", mappings = {close = {"q", "<esc>", "<c-o>"}}}
})

-- get handles of output windows
local function get_output_windows(activate_last)
    local target_regex = vim.regex('\\v^.*/python3|codelldb$')
    local handles = {}

    for _, handle in ipairs(vim.api.nvim_list_bufs()) do
        if target_regex:match_str(vim.api.nvim_buf_get_name(handle)) and
            vim.api.nvim_buf_is_loaded(handle) then
            table.insert(handles, handle)
        end
    end

    -- make last output buffer active, if visible
    if activate_last and handles[#handles] then
        local windows = vim.fn.win_findbuf(handles[#handles])

        if windows[#windows] then
            vim.api .nvim_buf_set_option(handles[#handles], 'bufhidden', 'delete')
            vim.fn.win_gotoid(windows[#windows])
        end
    end

    return handles
end

-- close servers launched within neovim
local function close_internal_servers()
    local buffers = vim.api.nvim_list_bufs()

    core.foreach(internal_servers, function(title)
        for _, handle in ipairs(buffers) do
            if vim.api.nvim_buf_get_name(handle):match('^.*/' .. title) then
                vim.api.nvim_buf_delete(handle, {force = true})
            end
        end
    end)
end

-- remove debugging keymaps
local function remove_maps()
    utils.unmap('n', '<m-d>B')
    utils.unmap({'n', 'v'}, '<m-d>k')
    utils.unmap('n', '<m-1>')
    utils.unmap('n', '<m-2>')
    utils.unmap('n', '<m-3>')
    utils.unmap('n', '<m-q>')
    utils.unmap('n', '<f4>')
end

-- setup debugging keymaps
local function setup_maps()
    utils.map('n', '<m-d>B', function()
        local condition = vim.fn.input('breakpoint condition: ')
        if condition then dap.set_breakpoint(condition) end
    end)

    utils.map({'n', 'v'}, '<m-d>k', dapui.eval)
    utils.map('n', '<m-1>', dap.step_over)
    utils.map('n', '<m-2>', dap.step_into)
    utils.map('n', '<m-3>', dap.step_out)

    -- hard terminate: remove keymaps, close dapui, close dap repl, close dap,
    -- delete output buffers, close internal_servers
    utils.map('n', '<m-q>', function()
        local session_tab = dap.session().session_target_tab

        remove_maps()
        dapui.close()
        dap.repl.close()
        dap.close()

        close_internal_servers() -- close servers launched within neovim

        -- close output windows
        core.foreach(get_output_windows(), function(handle)
            vim.api.nvim_buf_delete(handle, {force = true})
        end)

        -- close debugging tab
        vim.cmd('tabclose ' .. session_tab)
    end)

    utils.map('n', '<f4>', dapui.toggle)
end

-- start session: setup keymaps, open dapui
local function start_session()
    setup_maps()
    dapui.open()

    -- force local statusline
    require('lib/misc').toggle_global_statusline(true)

    require('notify')(string.format('[prog] %s', dap.session().config.program),
                      'debug', {title = '[dap] session started', timeout = 500})
end

-- terminate session: remove keymaps, close dapui, close dap repl,
-- close internal_servers, set last output buffer active
local function terminate_session()
    remove_maps()
    dapui.close()
    dap.repl.close()

    close_internal_servers() -- close servers launched within neovim
    get_output_windows(true) -- set last output window active

    require('notify')(string.format('[prog] %s', dap.session().config.program),
                      'debug',
                      {title = '[dap] session terminated', timeout = 500})
end

-- dap events
dap.listeners.after.event_initialized["dapui"] = start_session
dap.listeners.before.event_terminated["dapui"] = terminate_session
-- dap.listeners.before.event_exited["dapui"] = terminate_session

-- signs
vim.fn.sign_define("DapStopped", {text = '=>', texthl = 'DiagnosticWarn'})
vim.fn.sign_define("DapBreakpoint", {text = '<>', texthl = 'DiagnosticInfo'})
vim.fn.sign_define("DapBreakpointRejected", {text = '!>', texthl = 'DiagnosticError'})
vim.fn.sign_define("DapBreakpointCondition", {text = '?>', texthl = 'DiagnosticInfo'})
vim.fn.sign_define("DapLogPoint", {text = '.>', texthl = 'DiagnosticInfo'})

-- general keymaps
utils.map('n', '<m-d>b', dap.toggle_breakpoint)
utils.map('n', '<f5>', function()
    -- create debugging tab if needed
    if dap.session() == nil then
        vim.cmd('tab sb ' .. vim.api.nvim_win_get_buf(0))
    else
        vim.cmd('normal ' .. dap.session().session_target_tab .. 'gt')
    end

    dap.continue()
    dap.session().session_target_tab = vim.fn.tabpagenr()

end)

return {remove_maps = remove_maps, setup_maps = setup_maps}
