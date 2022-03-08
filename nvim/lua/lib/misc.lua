local core = require("lib/core")

-- convert fzf items to locations
local fzf_to_locations = function(entry)
    local split = vim.split(entry, ":")
    local position = { line = tonumber(split[2]) - 1, character = tonumber(split[3]) - 1 }

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

-- strip filename from full path
local function strip_fname(path) return vim.fn.fnamemodify(path, ':t:r') end

-- get vim cwd
local function get_cwd() return vim.fn['getcwd']() end

-- get git repo root dir (or nil)
local function get_git_root()
    local git_cmd = 'git -C ' .. get_cwd() .. ' rev-parse --show-toplevel'
    local root, rc = core.lua_systemlist(git_cmd)

    if rc == 0 then return root[1] end
    return nil
end

return {
    fzf_to_locations = fzf_to_locations,
    fzf_to_qf = fzf_to_qf,
    strip_fname = strip_fname,
    get_cwd = get_cwd,
    get_git_root = get_git_root
}
