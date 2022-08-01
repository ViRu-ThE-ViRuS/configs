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

-- pos in range
local function in_range (pos, range)
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
            vim.diagnostic.setqflist({open=false})
            utils.diagnostics_state['global'] = true

            vim.cmd [[
                belowright copen
                setlocal statusline=%!v:lua.StatusLine('Workspace\ Diagnostics')
                wincmd p
            ]]
        else
            utils.diagnostics_state['global'] = false
            vim.cmd [[ cclose ]]
        end
     else
         local current_buf = vim.api.nvim_get_current_buf()

         if not utils.diagnostics_state['local'][current_buf] then
             vim.diagnostic.setloclist()
             utils.diagnostics_state['local'][current_buf] = true

             vim.opt_local.statusline = require('statusline').StatusLine('Diagnostics')
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
    for position = #symbols, 1, -1 do
        local current = symbols[position]

        if current.range and in_range(hovered_line, current.range) then
            utils.tag_state.context[bufnr] = {
                kind = current.kind,
                name = current.name,
                detail = current.detail,
                icon = lsp_icons[current.kind].icon,
                iconhl = lsp_icons[current.kind].hl
            }

            return
        end
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
            utils.tag_state.req_state[bufnr].waiting = false
            if not vim.api.nvim_buf_is_valid(bufnr) then return end
            if results == nil or type(results) ~= 'table' then return end

            local extracted = extract_symbols(results)
            local symbols = core.filter(extracted, function(_, value) return tag_state_filter[value.kind] end)

            if not symbols or #symbols == 0 then return end
            utils.tag_state.cache[bufnr] = symbols
        end)
end

return {
    lsp_icons = lsp_icons,
    toggle_diagnostics_list = toggle_diagnostics_list,

    update_tags = update_tags,
    update_context = update_context,
    clear_buffer_tags = clear_buffer_tags
}

