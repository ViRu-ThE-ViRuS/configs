local core = require("lib/core")

--- {{{ global states
-- editor config and state
local editor_config = {
    -- state: current contexts using lsp+ts, update from lsp autocmds
    tag_state = {
        cache = {},
        context = {},
        req_state = {}
    },

    -- state: ui toggles
    ui_state = {
        thick_separators = false,
        window_state = {},

        -- state: diagnostics toggle
        diagnostics_state = {
            ["local"] = {},
            ["global"] = false,
        },

        -- set context in winbar
        -- use corresponding toggle to set this on
        context_winbar = false,
    },

    -- config: separator map
    symbol_config = {
        -- indicators, icons
        indicator_seperator = "",
        indicator_hint = "[@]",
        indicator_info = "[i]",
        indicator_warning = "[!]",
        indicator_error = "[x]",

        -- signs
        sign_hint = "@",
        sign_info = "i",
        sign_warning = "!",
        sign_error = "x",
    },

    -- truncation levels
    truncation = {
        truncation_limit_s_terminal = 110,
        truncation_limit_s = 80,
        truncation_limit = 100,
        truncation_limit_l = 160,
    }
}

-- workspace config and state
local workspace_config = {
    -- state: current run_config, works with terminal.lua api
    run_config = {
        target_terminal = nil,
        target_command = "",
    },

    -- registered custom commands
    commands = {},

    -- debug print setup
    debug_print_postfix = '__DEBUG_PRINT__',
    debug_print_fmt = {
        lua = 'print("%s:", vim.inspect(%s))',
        c = 'printf("%s: %%s", %s);',
        cpp = 'std::cout << "%s:" << %s << std::endl;',
        python = 'print(f"%s: {str(%s)}")',
    },
}
-- }}}

-- setup keymaps
local function map(mode, lhs, rhs, opts)
    local options = { noremap = true }
    if opts then options = vim.tbl_extend("force", options, opts) end
    vim.keymap.set(mode, lhs, rhs, options)
end

-- remove keymaps
local function unmap(mode, lhs, options)
    options = options or {}

    -- vim.keymap.del(mode, lhs, options)
    pcall(vim.keymap.del, mode, lhs, options)
end

-- set qflist and open
local function qf_populate(lines, mode, title, scroll_to_end)
    if mode == nil or type(mode) == "table" then
        lines = core.foreach(lines, function(_, item) return { filename = item, lnum = 1, col = 1, text = item } end)
        mode = "r"
    end

    vim.fn.setqflist(lines, mode)

    local commands = {
        'belowright copen',
        (scroll_to_end and 'normal! G') or "",
        (title and require('statusline').set_statusline_cmd(title)) or "",
        'wincmd p'
    }

    vim.cmd(table.concat(commands, '\n'))
end

-- notify using current notifications setup
local function notify(content, type, opts, force)
    if force then
        -- if packer_plugins['nvim-notify'].loaded then
        --     require('notify')(content, type, opts)
        -- end

        require("notify")(content, type, opts)
        return
    end

    vim.notify(content, type, opts)
end

-- is buffer horizontally truncated
local function is_htruncated(width, global)
    local current_width = (global and vim.api.nvim_get_option_value('columns', { scope = 'global' })) or
        vim.api.nvim_win_get_width(0)
    return current_width <= width
end

-- is buffer vertical truncated
local function is_vtruncated(height, global)
    local current_height = (global and vim.api.nvim_get_option_value('lines', { scope = 'global' })) or
        vim.api.nvim_win_get_height(0)
    return current_height <= height
end

-- add custom command
local function add_command(key, callback, cmd_opts, also_custom)
    -- opts defined, create user command
    if cmd_opts and next(cmd_opts) then
        vim.api.nvim_create_user_command(key, callback, cmd_opts)
        key = '[CMD] ' .. key
    end

    -- create custom command
    if also_custom then

        -- assert opts not defined, or 0 args
        assert((not cmd_opts) or (not cmd_opts.nargs) or cmd_opts.nargs == 0)

        local callback_fn = (type(callback) == 'function' and callback) or function()
            vim.api.nvim_command(callback)
        end
        workspace_config.commands[key] = callback_fn
    end
end

return {
    -- utils
    map = map,
    unmap = unmap,
    qf_populate = qf_populate,
    notify = notify,
    is_htruncated = is_htruncated,
    is_vtruncated = is_vtruncated,
    add_command = add_command,

    -- config and states
    editor_config = editor_config,
    workspace_config = workspace_config
}
