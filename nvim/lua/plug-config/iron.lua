require('iron.core').setup({
    config = {
        should_map_plug = false,
        scratch_repl = true,
        repl_definition = {
            python = {
                command = { "ipython" },
                format = require("iron.fts.common").bracketed_paste,
            },
        },
        repl_open_cmd = 'vsp'
    },
    keymaps = {
        send_line = "<leader>cv",
        visual_send = "<leader>cv",
    }
})
