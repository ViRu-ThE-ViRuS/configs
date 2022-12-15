local core = require("lib/core")

--- {{{ global states
-- lsp+ts: current tag_state [updated async]
local tag_state = {
    cache = {},
    context = {},
    req_state = {}
}

-- terminal: current run_config [updated elsewhere]
local run_config = {
    target_terminal = nil,
    target_command = "",
}

-- diagnostics: toggle state
local diagnostics_state = {
    ["local"] = {},
    ["global"] = false,
}

-- ui: toggles
local ui_state = {
    thick_separators = false,
    window_state = {},
}

-- registered custom commands
local commands = {
    keys = { },
    callbacks = { }
}

-- project config
local project_config = {
    debug_print_fmt = {
        lua = 'print("%s:", vim.inspect(%s))',
        c = 'printf("%s: %%s", %s);',
        cpp = 'std::cout << "%s:" << %s << std::endl;',
        python = 'print(f"%s: {str(%s)}")',
    },
    debug_print_postfix = '__DEBUG_PRINT__'
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
local function qf_populate(lines, mode, title)
	if mode == nil or type(mode) == "table" then
		lines = core.foreach(lines, function(item) return { filename = item, lnum = 1, col = 1, text = item } end)
		mode = "r"
	end

	vim.fn.setqflist(lines, mode)

	if not title then
		vim.cmd [[
            belowright copen
            wincmd p
        ]]
	else
        vim.cmd(string.format("belowright copen\n%s\nwincmd p",
            require('statusline').set_statusline_cmd(title)))
	end
end

-- notify using current  notifications setup
local function notify(content, type, opts, force)
	if force then
		-- if packer_plugins['nvim-notify'] ~= nil and packer_plugins['nvim-notify'].loaded then
		--     require('notify')(content, type, opts)
		-- end

		require("notify")(content, type, opts)
		return
	end

	vim.notify(content, type, opts)
end

-- is buffer horizontally truncated
local function is_htruncated(width, global)
    local current_width = (global and vim.api.nvim_get_option_value('columns', { scope = 'global'})) or vim.api.nvim_win_get_width(0)
	return current_width <= width
end

-- is buffer vertical truncated
local function is_vtruncated(height, global)
	local current_height = (global and vim.api.nvim_get_option_value('lines', { scope = 'global' })) or vim.api.nvim_win_get_height(0)
	return current_height <= height
end

-- add custom command
local function add_command(key, callback, cmd_opts, also_custom)
    -- opts defined, create user command
    if cmd_opts and next(cmd_opts) then
        vim.api.nvim_create_user_command(key, callback, cmd_opts)
    end

    -- create custom command
    if also_custom then

        -- assert opts not defined, or 0 args
        assert((not cmd_opts) or (not cmd_opts.nargs) or cmd_opts.nargs == 0)
        if commands.callbacks[key] == nil then table.insert(commands.keys, key) end

        if type(callback) == 'function' then commands.callbacks[key] = callback
        else commands.callbacks[key] = function() vim.api.nvim_command(callback) end end
    end
end

return {
	truncation_limit_s_terminal = 110,
	truncation_limit_s = 80,
	truncation_limit = 100,
	truncation_limit_l = 160,

	map = map,
	unmap = unmap,
	qf_populate = qf_populate,
	notify = notify,
	is_htruncated = is_htruncated,
	is_vtruncated = is_vtruncated,
    add_command = add_command,

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
	modes = {
		["n"]  = "Normal",
		["no"] = "N-Pending",
		["v"]  = "Visual",
		["V"]  = "V-Line",
		[""] = "V-Block",
		["s"]  = "Select",
		["S"]  = "S-Line",
		[""] = "S-Block",
		["i"]  = "Insert",
		["ic"] = "Insert",
		["R"]  = "Replace",
		["Rv"] = "V-Replace",
		["c"]  = "Command",
		["cv"] = "Vim-Ex ",
		["ce"] = "Ex",
        ["r"]  = "Prompt",
        ["rm"] = "More",
        ["r?"] = "Confirm",
        ["!"]  = "Shell",
        ["t"]  = "Terminal",
    },
    statusline_colors = {
        active      = "%#StatusLine#",
        inactive    = "%#StatusLineNC#",
        mode        = "%#PmenuSel#",
        git         = "%#Pmenu#",
        diagnostics = "%#PmenuSbar#",
        file        = "%#CursorLine#",
        context     = "%#PmenuSbar#",
        line_col    = "%#CursorLine#",
        percentage  = "%#CursorLine#",
        bufnr       = "%#PmenuSbar#",
        filetype    = "%#PmenuSel#",
    },

    tag_state = tag_state,
    run_config = run_config,
    diagnostics_state = diagnostics_state,
    ui_state = ui_state,
    commands = commands,
    project_config = project_config
}
