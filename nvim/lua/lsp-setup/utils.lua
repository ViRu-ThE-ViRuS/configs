local proto = require('vim.lsp.protocol')
local utils = require('utils')
local core = require('lib/core')

-- lsp int(kind) -> str(kind) map
local lsp_kinds = {
    "File", "Module", "Namespace", "Package", "Class", "Method", "Property",
    "Field", "Constructor", "Enum", "Interface", "Function", "Variable",
    "Constant", "String", "Number", "Boolean", "Array", "Object", "Key", "Null",
    "EnumMember", "Struct", "Event", "Operator", "TypeParameter"
}

-- lsp str(kind) -> icon(kind)
local lsp_icons = {
    File          = {icon = "",    hl = "TSURI"},
    Module        = {icon = "",    hl = "TSNamespace"},
    Namespace     = {icon = "",    hl = "TSNamespace"},
    Package       = {icon = "",    hl = "TSNamespace"},
    Class         = {icon = "𝓒",    hl = "TSType"},
    Method        = {icon = "ƒ",    hl = "TSMethod"},
    Property      = {icon = "",    hl = "TSMethod"},
    Field         = {icon = "",    hl = "TSField"},
    Constructor   = {icon = "",    hl = "TSConstructor"},
    Enum          = {icon = "ℰ",    hl = "TSType"},
    Interface     = {icon = "ﰮ",    hl = "TSType"},
    Function      = {icon = "",    hl = "TSFunction"},
    Variable      = {icon = "",    hl = "TSConstant"},
    Constant      = {icon = "",    hl = "TSConstant"},
    String        = {icon = "𝓐",    hl = "TSString"},
    Number        = {icon = "#",    hl = "TSNumber"},
    Boolean       = {icon = "⊨",    hl = "TSBoolean"},
    Array         = {icon = "",    hl = "TSConstant"},
    Object        = {icon = "⦿",    hl = "TSType"},
    Key           = {icon = "🔐",   hl = "TSType"},
    Null          = {icon = "NULL", hl = "TSType"},
    EnumMember    = {icon = "",    hl = "TSField"},
    Struct        = {icon = "𝓢",    hl = "TSType"},
    Event         = {icon = "🗲",    hl = "TSType"},
    Operator      = {icon = "+",    hl = "TSOperator"},
    TypeParameter = {icon = "𝙏",    hl = "TSParameter"}
}

-- toggle diagnostics list
local function toggle_diagnostics_list(global)
    if global then
        if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.quickfix")) == 1 then
            vim.diagnostic.setqflist()
            vim.opt_local.statusline = require('statusline').StatusLine('Diagnostics')
            vim.cmd [[ wincmd p ]]
        else
            vim.cmd [[ cclose ]]
        end
    else
        if vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.loclist")) == 1 then
            vim.diagnostic.setloclist()
            vim.opt_local.statusline = require('statusline').StatusLine('Workspace Diagnostics')
            vim.cmd [[ wincmd p ]]
        else
            vim.cmd [[ lclose ]]
        end
    end
end

-- print lsp diagnostics in CMD line
local function cmd_line_diagnostics()
    local line_number = vim.api.nvim_win_get_cursor(0)[1] - 1
    local line_diagnostics = vim.diagnostic.get(0, {lnum = line_number})
    local line_diagnostic = line_diagnostics[#line_diagnostics]

    if line_diagnostic then
        local message = line_diagnostic.message
        local severity_level = line_diagnostic.severity

        local severity = 'seperator'
        if severity_level == 4 then severity = 'hint'
        elseif severity_level == 3 then severity = 'info'
        elseif severity_level == 2 then severity = 'warning'
        elseif severity_level == 1 then severity = 'error' end

        print(utils.symbol_config['indicator_' .. severity] .. ': ' .. message)
    end
end

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

-- reset tag state
local reset_tag_state = function()
    utils.tag_state.kind = nil
    utils.tag_state.name = nil
    utils.tag_state.detail = nil
    utils.tag_state.icon = nil
    utils.tag_state.iconhl = nil
end

-- update tag_state async
local function refresh_tag_state()
    vim.lsp.buf_request(0, 'textDocument/documentSymbol', { textDocument = vim.lsp.util.make_text_document_params() },
        function(_, results, _, _)
            if results == nil or type(results) ~= 'table' then
                reset_tag_state()
                return
            end

            local extracted = extract_symbols(results)
            local symbols = core.filter(extracted, function(_, value) return tag_state_filter[value.kind] end)

            if not symbols or #symbols == 0 then
                reset_tag_state()
                return
            end

            local hovered_line = vim.api.nvim_win_get_cursor(0)
            for position = #symbols, 1, -1 do
                local current = symbols[position]

                if current.range and core.in_range(hovered_line, current.range) then
                    utils.tag_state.kind = current.kind
                    utils.tag_state.name = current.name
                    utils.tag_state.detail = current.detail
                    utils.tag_state.icon = lsp_icons[utils.tag_state.kind].icon
                    utils.tag_state.iconhl = lsp_icons[utils.tag_state.kind].hl

                    return
                end
            end
        end)
end

-- setup statusline icon highlights
local function setup_lsp_icon_highlights()
end

return {
    lsp_icons = lsp_icons,
    toggle_diagnostics_list = toggle_diagnostics_list,
    cmd_line_diagnostics = cmd_line_diagnostics,
    reset_tag_state = reset_tag_state,
    refresh_tag_state = refresh_tag_state,
    setup_lsp_icon_highlights = setup_lsp_icon_highlights
}

