local utils = require('utils')

-- module export
M = {}

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
M.get_lsp_icon = function (key)
    return lsp_icons[key].icon
end

-- lsp diagnostic list visible?
local diagnostics_set = {}

-- toggle diagnostics list
M.toggle_diagnostics_list = function()
    local current_buf = vim.api.nvim_get_current_buf()

    if not diagnostics_set[current_buf] then
        vim.diagnostic.setloclist()
        diagnostics_set[current_buf] = true

        vim.opt_local.buflisted = false
        vim.opt_local.number = true
        vim.opt_local.signcolumn = 'no'
        vim.opt_local.bufhidden = 'wipe'
        vim.opt_local.filetype = 'diagnostics'
        vim.opt_local.syntax = 'qf'
        vim.opt_local.statusline = require('statusline').StatusLine('Diagnostics')

        vim.cmd [[ wincmd p ]]
    else
        diagnostics_set[current_buf] = false
        vim.cmd [[ lclose ]]
    end
end

-- print lsp diagnostics in CMD line
M.cmd_line_diagnostics = function ()
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

-- reset tag state
local reset_tag_state = function()
    utils.tag_state.kind = nil
    utils.tag_state.name = nil
    utils.tag_state.detail = nil
    utils.tag_state.icon = nil
    utils.tag_state.iconhl = nil
end

-- update tag_state async
M.refresh_tag_state = function()
    local hovered_line = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]

    vim.lsp.buf_request(0, 'textDocument/documentSymbol', { textDocument = vim.lsp.util.make_text_document_params() },
        function(_, results, _, _)
            if results == nil or type(results) ~= 'table' then
                reset_tag_state()
                return
            end

            for _, result in pairs(results) do
                local range = result.range
                if result.range == nil then
                    range = result.location.range
                end

                if range['start']['line'] <= hovered_line and
                    hovered_line <= range['end']['line'] then

                    utils.tag_state.kind = lsp_kinds[result.kind]
                    utils.tag_state.name = result.name
                    utils.tag_state.detail = result.detail
                    utils.tag_state.icon = lsp_icons[utils.tag_state.kind].icon
                    utils.tag_state.iconhl = lsp_icons[utils.tag_state.kind].hl
                    break
                end
            end
        end)
    -- reset_tag_state()
end

-- setup statusline icon highlights
M.setup_lsp_icon_highlights = function()
    return
end

return M

