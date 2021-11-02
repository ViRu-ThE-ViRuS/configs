_G.qf_populate = require("utils").qf_populate
require("lspfuzzy").setup {
    methods = {"textDocument/definition", "textDocument/references"},
    fzf_action = {['ctrl-q'] = 'v:lua.qf_populate'}
}
