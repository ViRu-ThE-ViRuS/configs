return {
    'mfussenegger/nvim-dap',
    dependencies = { 'rcarriga/nvim-dap-ui', 'theHamsta/nvim-dap-virtual-text' },
    ft = { 'c', 'cpp', 'rust', 'python' },
    config = function()
        local dap = require('dap')
        local dapui = require('dapui')
        local utils = require('utils')
        local core = require('lib/core')

        -- NOTE(vir): use mason to install dependencies
        -- mason is already setup by lsp config
        require('mason-nvim-dap').setup({ ensure_installed = { 'python', 'codelldb' } })

        -- {{{ adapters
        -- servers launched internally in neovim
        local internal_servers = {}

        -- adapters
        dap.adapters.python = {
            type = 'executable',
            command = 'debugpy-adapter'
        }

        dap.adapters.codelldb = {
            type = 'server',
            port = '13000',
            executable = {
                command = 'codelldb',
                args = { '--port', '13000' },
            },
        }

        -- TODO(vir): fix this
        -- load extra js/ts dependencies
        -- _ = (function()
        --     local ft = vim.api.nvim_get_option_value('ft', { scope = 'local' })
        --     local targets = { 'javascript', 'javascriptreact', 'typescript', 'typescriptreact' }

        --     if not core.table_contains(targets, ft) then return end

        --     -- load if needed and not already present
        --     -- this is to get around packer messing up ordering
        --     if not packer_plugins['nvim-dap-vscode-js'].loaded then
        --         require('packer').loader('nvim-dap-vscode-js')
        --     end

        --     require('dap-vscode-js').setup({
        --         adapters = { 'pwa-node' },
        --         debugger_path = core.get_homedir() .. '/.local/vscode-js-debug',
        --     })
        -- end)()
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
                    -- want it in cmdline, without callback. so fn.input better than ui.input
                    return vim.fn.input('executable: ', vim.loop.cwd() .. '/', 'file')
                end
            }
        }
        dap.configurations.cpp = dap.configurations.c
        dap.configurations.rust = dap.configurations.cpp

        -- TODO(vir): fix this
        -- dap.configurations.javascript = {
        --     {
        --         type = 'pwa-node',
        --         request = 'launch',
        --         name = 'launch',
        --         program = '${file}',
        --         sourceMaps = true,
        --         cwd = '${workspaceFolder}',
        --         rootPath = '${workspaceFolder}',
        --         skipFiles = { '<node_internals>/**' },
        --         protocol = 'inspector',
        --         console = 'integratedTerminal',
        --         resolveSourceMapLocations = {
        --             "${workspaceFolder}/dist/**/*.js",
        --             "${workspaceFolder}/**",
        --             "!**/node_modules/**",
        --         },
        --     },
        --     {
        --         type = 'pwa-node',
        --         request = 'attach',
        --         name = 'attach',
        --         processId = require('dap/utils').pick_process,
        --         cwd = '${workspaceFolder}'

        --     }
        -- }
        -- dap.configurations.typescript = dap.configurations.javascript
        -- dap.configurations.javascriptreact = dap.configurations.javascript
        -- dap.configurations.typescriptreact = dap.configurations.javascript
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
        -- vim.api.nvim_create_augroup('DAPConfig', { clear = true })
        -- vim.api.nvim_create_autocmd('FileType', {
        --     group = 'DAPConfig',
        --     pattern = 'dap-repl',
        --     callback = require('dap.ext.autocompl').attach
        -- })

        -- signs
        vim.fn.sign_define("DapStopped", { text = '=>', texthl = 'DiagnosticWarn', numhl = 'DiagnosticWarn' })
        vim.fn.sign_define("DapBreakpoint", { text = '<>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })
        vim.fn.sign_define("DapBreakpointRejected",
            { text = '!>', texthl = 'DiagnosticError', numhl = 'DiagnosticError' })
        vim.fn.sign_define("DapBreakpointCondition", { text = '?>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })
        vim.fn.sign_define("DapLogPoint", { text = '.>', texthl = 'DiagnosticInfo', numhl = 'DiagnosticInfo' })

        dap.defaults.fallback.focus_terminal = false
        dap.defaults.fallback.terminal_win_cmd = '10split new'

        -- virtual text setup
        require('nvim-dap-virtual-text').setup({})
        -- }}}

        -- {{{ helpers
        -- get handles of output windows
        local function activate_output_window(session)
            local target_handle = nil
            local target_regex = nil

            -- NOTE(vir): manually update this when new adapters are added
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
                    target_handle = handle
                    break
                end
            end

            -- make last output buffer active, if visible
            if target_handle then
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
                    vim.api.nvim_set_current_win(windows[#windows])
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

            core.foreach(internal_servers, function(_, title)
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
                local session = dap.session()

                remove_maps()
                dapui.close()
                dap.repl.close()
                dap.close()

                close_internal_servers()
                activate_output_window(session)

                utils.notify(string.format('[prog] %s', session.config.program),
                    'debug', { title = '[dap] session closed', timeout = 500 }, true)
            end)

            utils.map('n', '<f4>', dapui.toggle)
        end

        -- }}}

        -- {{{ session management
        -- start session: setup keymaps, open dapui
        local function start_session(session, _)
            if session.config.program == nil then return end
            session.session_target_tab = vim.api.nvim_get_current_tabpage()

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

            close_internal_servers()
            activate_output_window(session)

            utils.notify(string.format('[prog] %s', session.config.program),
                'debug', { title = '[dap] session terminated', timeout = 500 }, true)
        end

        -- dap events
        dap.listeners.before.event_initialized["dapui"] = start_session
        -- dap.listeners.before.event_terminated["dapui"] = terminate_session
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
            if dap.session() == nil then vim.cmd('tab sb ' .. vim.api.nvim_get_current_buf())
            else vim.cmd('normal ' .. dap.session().session_target_tab .. 'gt') end
            dap.continue()
        end)
    end
}
