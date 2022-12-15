local dap = require('dap')
local dapui = require('dapui')
local utils = require('utils')
local core = require('lib/core')

-- {{{ adapters
-- servers launched internally in neovim
local internal_servers = { codelldb = 'codelldb server' }

-- adapters
dap.adapters.python = {
    type = 'executable',
    command = 'python3',
    args = { '-m', 'debugpy.adapter' }
}

dap.adapters.codelldb = function(callback, _)
    -- NOTE(vir): consider using vim jobstart api
    require('terminal').launch_terminal('codelldb', true, function()
        vim.api.nvim_buf_set_name(0, internal_servers.codelldb)
        vim.defer_fn(function()
            callback({ type = 'server', host = '127.0.0.1', port = 13000 })
        end, 1500)
    end)
end

if packer_plugins['nvim-dap-vscode-js'].loaded then
    require('dap-vscode-js').setup({
        adapters = {'pwa-node'},
        debugger_path = core.get_homedir() .. '/.local/vscode-js-debug',
    })
end
-- }}}

-- {{{ language configurations
dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        program = '${file}',
        cwd = '${workspaceFolder}',
        terminal = 'console',
        console = 'integratedTerminal',
        pythonPath = core.get_python()
    }
}

dap.configurations.c = {
    {
        type = "codelldb",
        request = "launch",
        cwd = '${workspaceFolder}',
        terminal = 'integrated',
        console = 'integratedTerminal',
        stopOnEntry = false,
        program = function()
            return vim.fn.input('executable: ', vim.fn.getcwd() .. '/', 'file')
        end
    }
}
dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.cpp

dap.configurations.javascript = {
    {
        type = 'pwa-node',
        request = 'launch',
        program = '${file}',
        sourceMaps = true,
        cwd = '${workspaceFolder}'
    }
}
--- }}}

-- {{{ ui setup
-- repl setup
dap.repl.commands = vim.tbl_extend('force', dap.repl.commands, {
    exit = { 'q', 'exit' },
    custom_commands = {
        ['.run_to_cursor'] = dap.run_to_cursor,
        ['.restart'] = dap.run_last
    }
})

-- dapui setup
dapui.setup({
    mappings = {
        expand = "<CR>",
        open = "o",
        remove = "D",
        edit = "e",
        repl = "r",
        toggle = "t",
    },
    layouts = {
        { elements = { "scopes", "breakpoints", "stacks" }, size = 0.33, position = "right" },
        { elements = { "repl", "watches" }, size = 0.27, position = "bottom" },
    },
    icons = { expanded = "-", collapsed = "$" },
    controls = { enabled = false },
    floating = { border = "rounded", mappings = { close = { "q", "<esc>", "<c-o>" } } },
})

-- autocmds
vim.api.nvim_create_augroup('DAPConfig', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
    group = 'DAPConfig',
    pattern = 'dap-repl',
    callback = require('dap.ext.autocompl').attach
})

-- signs
vim.fn.sign_define("DapStopped", { text = '=>', texthl = 'DiagnosticWarn', numhl = 'DiagnosticWarn' })
vim.fn.sign_define("DapBreakpoint", { text = '<>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })
vim.fn.sign_define("DapBreakpointRejected", { text = '!>', texthl = 'DiagnosticError', numhl = 'DiagnosticError' })
vim.fn.sign_define("DapBreakpointCondition", { text = '?>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })
vim.fn.sign_define("DapLogPoint", { text = '.>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })

dap.defaults.fallback.focus_terminal = false
dap.defaults.fallback.terminal_win_cmd = '10split new'

-- virtual text setup
require('nvim-dap-virtual-text').setup({})
-- }}}

-- {{{ helpers
-- get handles of output windows
local function get_output_windows(session, activate_last)
    local target_handle = nil
    local target_regex = nil

    if session.config.type == 'pwa-node' then
        target_regex = vim.regex('\\v^.*/.*dap-repl.*$')
        dap.repl.open()
    else
        target_regex = vim.regex('\\v^.*/python3|codelldb$')
    end

    -- get buffer handle for output window
    for _, handle in ipairs(vim.api.nvim_list_bufs()) do
        if target_regex:match_str(vim.api.nvim_buf_get_name(handle)) and
            vim.api.nvim_buf_is_loaded(handle) then
            target_handle =  handle
            break
        end
    end

    -- make last output buffer active, if visible
    if activate_last and target_handle then
        vim.api.nvim_buf_set_option(target_handle, 'bufhidden', 'delete')
        utils.map('n', '<c-o>', function()
            vim.cmd [[
                    q!
                    tabclose
                ]]
        end, { buffer = target_handle })

        local windows = vim.fn.win_findbuf(target_handle)
        if windows[#windows] then
            -- activate it if visible
            vim.fn.win_gotoid(windows[#windows])
        else
            -- split it otherwise
            vim.cmd('25split #' .. target_handle)
        end
    end

    return target_handle
end

-- close servers launched within neovim
local function close_internal_servers()
    local buffers = vim.api.nvim_list_bufs()

    core.foreach(internal_servers, function(title)
        for _, handle in ipairs(buffers) do
            if vim.api.nvim_buf_get_name(handle):match('^.*/' .. title) then
                vim.api.nvim_buf_delete(handle, { force = true })
            end
        end
    end)
end
-- }}}

-- {{{ dap keymaps
-- remove debugging keymaps
local function remove_maps()
    utils.unmap({ 'n', 'v' }, '<m-d>k')
    utils.unmap('n', '<m-1>')
    utils.unmap('n', '<m-2>')
    utils.unmap('n', '<m-3>')
    utils.unmap('n', '<m-q>')
    utils.unmap('n', '<f4>')
end

-- setup debugging keymaps
local function setup_maps()
    utils.map({ 'n', 'v' }, '<m-d>k', dapui.eval)
    utils.map('n', '<m-1>', dap.step_over)
    utils.map('n', '<m-2>', dap.step_into)
    utils.map('n', '<m-3>', dap.step_out)

    -- hard terminate: remove keymaps, close dapui, close dap repl, close dap,
    -- delete output buffers, close internal_servers
    utils.map('n', '<m-q>', function()
        remove_maps()
        dapui.close()
        dap.repl.close()

        -- close session tab
        vim.cmd('silent! tabclose ' .. dap.session().session_target_tab)
        dap.close()

        close_internal_servers() -- close servers launched within neovim

        -- close output windows
        core.foreach(get_output_windows(), function(handle)
            vim.api.nvim_buf_delete(handle, { force = true })
        end)
    end)

    utils.map('n', '<f4>', dapui.toggle)
end
-- }}}

-- {{{ session management
-- start session: setup keymaps, open dapui
local function start_session(session, _)
    if session.config.program == nil then return end
    session.session_target_tab = vim.fn.tabpagenr()

    setup_maps()
    dapui.open()

    -- force local statusline
    require('lib/misc').toggle_global_statusline(true)

    utils.notify(string.format('[prog] %s', session.config.program),
        'debug', { title = '[dap] session started', timeout = 500 }, true)
end

-- terminate session: remove keymaps, close dapui, close dap repl,
-- close internal_servers, set last output buffer active
local function terminate_session(session, _)
    if session.config.program == nil then return end

    remove_maps()
    dapui.close()
    dap.repl.close()

    close_internal_servers() -- close servers launched within neovim
    get_output_windows(session, true) -- set last output window active

    utils.notify(string.format('[prog] %s', session.config.program),
        'debug', { title = '[dap] session terminated', timeout = 500 }, true)
end

-- dap events
dap.listeners.before.event_initialized["dapui"] = start_session
dap.listeners.before.event_terminated["dapui"] = terminate_session
dap.listeners.before.event_exited["dapui"] = terminate_session
-- }}}

-- general keymaps and commands
utils.map('n', '<m-d>b', dap.toggle_breakpoint)
utils.add_command('[DAP] debug: add conditional breakpoint', function()
    vim.ui.input({
        prompt = 'breakpoint condition> ',
        completion = 'tag'
    }, function(condition)
        dap.set_breakpoint(condition)
    end)
end, nil, true)

utils.map('n', '<f5>', function()
    -- create session tab if needed
    if dap.session() == nil then vim.cmd('tab sb ' .. vim.api.nvim_win_get_buf(0))
    else vim.cmd('normal ' .. dap.session().session_target_tab .. 'gt') end
    dap.continue()
end)

return { remove_maps = remove_maps, setup_maps = setup_maps }
