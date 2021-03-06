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
M.GetLSPIcon = function (key)
    return lsp_icons[key].icon
end

-- lsp diagnostic list visible?
local diagnostics_set = {}

-- toggle diagnostics list
M.ToggleDiagnosticsList = function()
    local current_buf = vim.api.nvim_get_current_buf()

    if not diagnostics_set[current_buf] then
        vim.lsp.diagnostic.set_loclist()
        diagnostics_set[current_buf] = true

        vim.cmd [[
            setlocal nobuflisted
            setlocal bufhidden=wipe
            setlocal signcolumn=no
            setlocal filetype=diagnostics
            wincmd p
        ]]
    else
        diagnostics_set[current_buf] = false
        vim.cmd [[ lclose ]]
    end
end

-- print lsp diagnostics in CMD line
M.CMDLineDiagnostics = function ()
    local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
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
local resetTagState = function()
    utils.TagState.kind = nil
    utils.TagState.name = nil
    utils.TagState.detail = nil
    utils.TagState.icon = nil
    utils.TagState.iconhl = nil
end

-- update TagState async
M.RefreshTagState = function()
    local hovered_line = vim.api.nvim_win_get_cursor(vim.api.nvim_get_current_win())[1]

    vim.lsp.buf_request(0, 'textDocument/documentSymbol', { textDocument = vim.lsp.util.make_text_document_params() },
        function(_, _, results, _)
            if results == nil or type(results) ~= 'table' then
                resetTagState()
                return
            end

            for _, result in pairs(results) do
                local range = result.range
                if result.range == nil then
                    range = result.location.range
                end

                if range['start']['line'] <= hovered_line and
                    hovered_line <= range['end']['line'] then

                    utils.TagState.kind = lsp_kinds[result.kind]
                    utils.TagState.name = result.name
                    utils.TagState.detail = result.detail
                    utils.TagState.icon = lsp_icons[utils.TagState.kind].icon
                    utils.TagState.iconhl = lsp_icons[utils.TagState.kind].hl
                    break
                end
            end
        end)
    -- resetTagState()
end

-- setup statusline icon highlights
M.SetupLspIconHighlights = function()
    return
end

return M

