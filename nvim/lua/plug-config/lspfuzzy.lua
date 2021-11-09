vim.g.fzf_layout = {["down"] = "40%"}

require("lspfuzzy").setup {
    methods = {"textDocument/definition", "textDocument/references"},
    fzf_preview = {"right:50%:+{2}-/2"},
    fzf_action = {
        ["ctrl-q"] = require("lib/misc").fzf_to_qf,
        ["ctrl-v"] = "vsplit",
        ["ctrl-x"] = "split"
    }
}

