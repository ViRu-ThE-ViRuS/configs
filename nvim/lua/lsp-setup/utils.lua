local proto = require('vim.lsp.protocol')
local utils = require('utils')
local core = require('lib/core')

-- tag states for statusline
local tag_state_filter = {
    Class     = true,
    Function  = true,
    Method    = true,
    Struct    = true,
    Enum      = true,
    Interface = true,
    Namespace = true,
    Module    = true,
}

-- lsp str(kind) -> icon(kind)
local lsp_icons = {
    File          = { icon = "", hl = "%#TSURI#" },
    Module        = { icon = "", hl = "%#TSNamespace#" },
    Namespace     = { icon = "", hl = "%#TSNamespace#" },
    Package       = { icon = "", hl = "%#TSNamespace#" },
    Class         = { icon = "𝓒", hl = "%#TSType#" },
    Method        = { icon = "ƒ", hl = "%#TSMethod#" },
    Property      = { icon = "", hl = "%#TSMethod#" },
    Field         = { icon = "", hl = "%#TSField#" },
    Constructor   = { icon = "", hl = "%#TSConstructor#" },
    Enum          = { icon = "ℰ", hl = "%#TSType#" },
    Interface     = { icon = "ﰮ", hl = "%#TSType#" },
    Function      = { icon = "", hl = "%#TSFunction#" },
    Variable      = { icon = "", hl = "%#TSConstant#" },
    Constant      = { icon = "", hl = "%#TSConstant#" },
    String        = { icon = "𝓐", hl = "%#TSString#" },
    Number        = { icon = "#", hl = "%#TSNumber#" },
    Boolean       = { icon = "⊨", hl = "%#TSBoolean#" },
    Array         = { icon = "", hl = "%#TSConstant#" },
    Object        = { icon = "⦿", hl = "%#TSType#" },
    Key           = { icon = "🔐", hl = "%#TSType#" },
    Null          = { icon = "NULL", hl = "%#TSType#" },
    EnumMember    = { icon = "", hl = "%#TSField#" },
    Struct        = { icon = "𝓢", hl = "%#TSType#" },
    Event         = { icon = "🗲", hl = "%#TSType#" },
    Operator      = { icon = "+", hl = "%#TSOperator#" },
    TypeParameter = { icon = "𝙏", hl = "%#TSParameter#" }
}

-- pos in range
local function in_range(pos, range)
    if pos[1] < range['start'].line or pos[1] > range['end'].line then
        return false
    end

    if (pos[1] == range['start'].line and pos[2] < range['start'].character) or
        (pos[1] == range['end'].line and pos[2] > range['end'].character) then
        return false
    end

    return true
end

-- toggle diagnostics list
local function toggle_diagnostics_list(global)
    if global then
        if not utils.diagnostics_state['global'] then
            vim.diagnostic.setqflist({ open = false })
            utils.diagnostics_state['global'] = true

            vim.cmd(string.format("belowright copen\n%s\nwincmd p",
                require('statusline').set_statusline_cmd('Workspace Diagnostics')))
        else
            utils.diagnostics_state['global'] = false
            vim.cmd [[ cclose ]]
        end
    else
        local current_buf = vim.api.nvim_get_current_buf()

        if not utils.diagnostics_state['local'][current_buf] then
            vim.diagnostic.setloclist()
            utils.diagnostics_state['local'][current_buf] = true

            require('statusline').set_statusline_func('Diagnostics')()
            vim.cmd [[ wincmd p ]]
        else
            utils.diagnostics_state['local'][current_buf] = false
            vim.cmd [[ lclose ]]
        end
    end
end

-- extract symbols from lsp results
local function extract_symbols(items, _result)
    local result = _result or {}
    if items == nil then return result end

    for _, item in ipairs(items) do
        local kind = proto.SymbolKind[item.kind] or 'Unknown'
        local symbol_range = item.range

        if not symbol_range then
            symbol_range = item.location.range
        end

        if symbol_range then
            symbol_range['start'].line = symbol_range['start'].line + 1
            symbol_range['end'].line = symbol_range['end'].line + 1
        end

        table.insert(result, {
            filename = item.location and vim.uri_to_fname(item.location.uri) or nil,
            range = symbol_range,
            kind = kind,
            name = item.name,
            detail = item.detail,
            raw = item
        })

        extract_symbols(item.children, result)
    end

    return result
end

-- clear buffer tags and context
local function clear_buffer_tags(bufnr)
    utils.tag_state.context[bufnr] = nil
    utils.tag_state.cache[bufnr] = nil
    utils.tag_state.req_state[bufnr] = nil
end

-- get current context
local function update_context()
    local bufnr = vim.fn.bufnr('%')
    local symbols = utils.tag_state.cache[bufnr]
    if not symbols or #symbols < 1 then return end

    local hovered_line = vim.api.nvim_win_get_cursor(0)
    local contexts = {}

    for position = #symbols, 1, -1 do
        local current = symbols[position]

        if current.range and in_range(hovered_line, current.range) then
            table.insert(contexts, {
                kind = current.kind,
                name = current.name,
                detail = current.detail,
                range = current.range,
                icon = lsp_icons[current.kind].icon,
                iconhl = lsp_icons[current.kind].hl
            })
        end
    end

    if #contexts > 0 then
        table.sort(contexts,
            function(a, b) return a.range['end'].line > b.range['end'].line or
                b.range['end'].character > b.range['end'].character
            end)
        utils.tag_state.context[bufnr] = contexts
        return
    end

    utils.tag_state.context[bufnr] = nil
end

-- update tag_state async
local function update_tags()
    local bufnr = vim.fn.bufnr('%')
    if utils.tag_state.req_state[bufnr] == nil then utils.tag_state.req_state[bufnr] = { waiting = false, last_tick = 0 } end

    if (not utils.tag_state.req_state[bufnr].waiting and utils.tag_state.req_state[bufnr].last_tick < vim.b.changedtick) then
        utils.tag_state.req_state[bufnr] = { waiting = true, last_tick = vim.b.changedtick }
    else return end

    vim.lsp.buf_request(bufnr, 'textDocument/documentSymbol', { textDocument = vim.lsp.util.make_text_document_params() },
        function(_, results, _, _)
            -- buffer might have closed by the time this request completed
            if not utils.tag_state.req_state[bufnr] then return end

            utils.tag_state.req_state[bufnr].waiting = false
            if not vim.api.nvim_buf_is_valid(bufnr) then return end
            if results == nil or type(results) ~= 'table' then return end

            local extracted = extract_symbols(results)
            local symbols = core.filter(extracted, function(_, value) return tag_state_filter[value.kind] end)

            if not symbols or #symbols == 0 then return end
            utils.tag_state.cache[bufnr] = symbols
        end)
end

-- custom refactoring functionality
local function debug_print(visual)
    local target_line = nil
    local target = nil
    local indent = nil

    -- NOTE(vir): no error handling, to remind me that i need to add missing config
    local ft = vim.api.nvim_get_option_value('filetype', { scope = 'local' })
    local template = require('utils').project_config.debug_print_fmt[ft]
    local postfix_raw = utils.project_config.debug_print_postfix
    local postfix = ' ' .. vim.api.nvim_get_option_value('commentstring', { scope = 'local' })
        :format(postfix_raw)

    if visual then
        local selection_start = vim.api.nvim_buf_get_mark(0, "<")
        local selection_end = vim.api.nvim_buf_get_mark(0, ">")

        local start_line = selection_start[1]
        local end_line = selection_end[1]
        local start_col = selection_start[2]
        local end_col = selection_end[2]

        -- only support single line selections
        if start_line ~= end_line then return end
        if end_col - start_col > 100 then return end

        local line = vim.api.nvim_buf_get_lines(0, start_line - 1, start_line, true)[1]
        local content = vim.api.nvim_buf_get_text(0, start_line - 1, start_col, start_line - 1, end_col + 1, {})[1]

        target_line = start_line - 1
        target = vim.trim(content)
        indent = require('lib/misc').calculate_indent(line, true)
    else
        local ts = require('nvim-treesitter/ts_utils')
        local current = ts.get_node_at_cursor(0)
        local start_line, _, end_line, _, _ = ts.get_node_range(current)

        -- only support single line nodes
        if start_line ~= end_line then return end
        local line = vim.api.nvim_buf_get_lines(0, start_line, start_line + 1, true)[1]

        target_line = start_line
        target = vim.treesitter.query.get_node_text(current, 0)
        indent = require('lib/misc').calculate_indent(line, true)
    end

    -- toggle print if already present
    local current_line = vim.api.nvim_buf_get_lines(0, target_line, target_line + 1, true)[1]
    local next_line = vim.api.nvim_buf_get_lines(0, target_line + 1, target_line + 2, true)[1]
    if next_line:find(postfix_raw) then
        vim.api.nvim_buf_set_lines(0, target_line + 1, target_line + 2, true, {})
        return
    end
    if current_line:find(postfix_raw) then
        vim.api.nvim_buf_set_lines(0, target_line, target_line + 1, true, {})
        return
    end

    -- insert debug print statement
    local debug_print_statement = indent .. template:format(target, target) .. postfix
    vim.api.nvim_buf_set_lines(0, target_line + 1, target_line + 1, false, { debug_print_statement })
end

return {
    lsp_icons = lsp_icons,
    toggle_diagnostics_list = toggle_diagnostics_list,

    update_tags = update_tags,
    update_context = update_context,
    clear_buffer_tags = clear_buffer_tags,

    debug_print = debug_print
}
