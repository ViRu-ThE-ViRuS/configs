local dap = require('dap')
local dapui = require('dapui')
local utils = require('utils')
local oslib = require('lib/oslib')

dap.adapters.codelldb = {type = 'server', host = '127.0.0.1', port = 13000}
dap.adapters.python = {type='executable', command='python3', args={'-m', 'debugpy.adapter'}}

dap.configurations.c = {
    {
        type = "codelldb",
        request = "launch",
        cwd = '${workspaceFolder}',
        console = 'integratedTerminal',
        stopOnEntry = false,
        program = function() return vim.fn.input('executable: ', vim.fn.getcwd() .. '/', 'file') end
    }
}

dap.configurations.cpp = dap.configurations.c
dap.configurations.rust = dap.configurations.cpp

dap.configurations.python = {
    {
        type = 'python',
        request = 'launch',
        program = '${file}',
        terminal = 'integrated',
        console = 'integratedTerminal',
        pythonPath = oslib.get_python(),
    }
}

dapui.setup({
    icons = {expanded = "-", collapsed = "$"},
    mappings = {
        expand = "<CR>",
        open = "o",
        remove = "d",
        edit = "e",
        repl = "r"
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
    floating = {border = "rounded", mappings = {close = "q"}}
})

local function setup_maps()
    utils.map('n', '<m-d>B', '<cmd>lua require("dap").set_breakpoint(vim.fn.input("breakpoint condition: ")<cr>')
    utils.map('n', '<m-d><m-1>', '<cmd>lua require("dap").step_over()<cr>')
    utils.map('n', '<m-d><m-2>', '<cmd>lua require("dap").step_into()<cr>')
    utils.map('n', '<m-d><m-3>', '<cmd>lua require("dap").step_out()<cr>')
    utils.map('n', '<m-d><m-q>', '<cmd>lua require("dap").close()<cr> ' ..
                                 '<cmd>lua require("dap").repl.close()<cr>' ..
                                 '<cmd>lua require("dapui").close()<cr>' ..
                                 '<cmd>lua require("plug-config/dap").remove_maps()<cr>')

    utils.map('n', '<m-d>k', '<cmd>lua require("dapui").eval()<cr>')
    utils.map('n', '<f4>', '<cmd>lua require("dapui").toggle()<cr>')
end

local function remove_maps()
    utils.unmap('n', '<m-d>B')
    utils.unmap('n', '<m-d><m-1>')
    utils.unmap('n', '<m-d><m-2>')
    utils.unmap('n', '<m-d><m-3>')
    utils.unmap('n', '<m-d><m-q>')
    utils.unmap('n', '<m-d>k')
    utils.unmap('n', '<f4>')
end

local function start_session()
    setup_maps()
    dapui.open()
end

local function terminate_session()
    remove_maps()
    dapui.close()
    dap.repl.close()
end

dap.listeners.after.event_initialized["dapui"] = start_session
dap.listeners.before.event_terminated["dapui"] = terminate_session
-- dap.listeners.before.event_exited["dapui"] = terminate_session

vim.fn.sign_define("DapBreakpoint", { text='<>', texthl='LspWarningVirtual' })

utils.map('n', '<m-d>b', '<cmd>lua require("dap").toggle_breakpoint()<cr>')
utils.map('n', '<f5>', '<cmd>lua require("dap").continue()<cr>')

return { remove_maps = remove_maps, setup_maps = setup_maps }
