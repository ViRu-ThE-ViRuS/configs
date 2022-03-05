require('gitsigns').setup {
    numhl = false,
    linehl = false,
    keymaps = {
        noremap = true,
        buffer = true,

        ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require(\"gitsigns\").next_hunk()<CR>'"},
        ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require(\"gitsigns\").prev_hunk()<CR>'"},

        ['n <leader>gs'] = '<cmd>lua require("gitsigns").stage_hunk()<CR>',
        ['n <leader>gu'] = '<cmd>lua require("gitsigns").undo_stage_hunk()<CR>',
        ['n <leader>gr'] = '<cmd>lua require("gitsigns").reset_hunk()<CR>',
        ['n <leader>gp'] = '<cmd>lua require("gitsigns").preview_hunk()<CR>',
        ['v <leader>gs'] = '<cmd>lua require("gitsigns").stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
        ['v <leader>gr'] = '<cmd>lua require("gitsigns").reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',

        ['o ig'] = ':<c-U>lua require("gitsigns").select_hunk()<CR>',
        ['x ig'] = ':<c-U>lua require("gitsigns").select_hunk()<CR>'
    }
}

