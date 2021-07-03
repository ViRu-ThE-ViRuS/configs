-- module export
M = {}

-- apply f to all elements in table
M.foreach = function(tbl, f)
    local t = {}

    for key, value in pairs(tbl) do
        t[key] = f(value)
    end

    return t
end

-- strip filename from full path
M.strip_fname = function(path)
    return vim.fn.fnamemodify(path, ':t:r')
end

return M
