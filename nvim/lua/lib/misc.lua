local core = require("lib/core")

-- convert fzf items to locations
local fzf_to_locations = function(entry)
    local split = vim.split(entry, ":")
    local position = {line = tonumber(split[2]) - 1, character = tonumber(split[3]) - 1}
    return {
        uri = vim.uri_from_fname(vim.fn.fnamemodify(split[1], ":p")),
        range = {start = position, ["end"] = position}
    }
end

-- populate qflist with fzf items
local fzf_to_qf = function(lines)
    local items = vim.lsp.util.locations_to_items(core.foreach(lines, fzf_to_locations))
    require("utils").qf_populate(items, "r")
end

-- pos in range
local in_range = function(pos, range)
    if pos[1] < range['start'].line or pos[1] > range['end'].line then return false end

    if (pos[1] == range['start'].line and pos[2] < range['start'].character) or
        (pos[1] == range['end'].line and pos[2] > range['end'].character) then return false end

    return true
end

return {
    fzf_to_locations = fzf_to_locations,
    fzf_to_qf = fzf_to_qf,
    in_range = in_range
}
