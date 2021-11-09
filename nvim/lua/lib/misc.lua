local core = require("lib/core")

-- module export
M = {}

-- convert fzf items to locations
local fzf_to_locations = function(entry)
    local split = vim.split(entry, ":")
    local position = {line = tonumber(split[2]) - 1, character = tonumber(split[3]) - 1}
    return {
        uri = vim.uri_from_fname(vim.fn.fnamemodify(split[1], ":p")),
        range = {start = position, ["end"] = position}
    }
end
M.fzf_to_locations = fzf_to_locations

-- populate qflist with fzf items
local fzf_to_qf = function(lines)
    local items = vim.lsp.util.locations_to_items(core.foreach(lines, fzf_to_locations))
    require("utils").qf_populate(items, "r")
end
M.fzf_to_qf = fzf_to_qf

return M
