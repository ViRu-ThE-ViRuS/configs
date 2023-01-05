return {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    init = function()
        local utils = require("utils")
        utils.map("n", "<leader>gh", "<cmd>DiffviewOpen<cr>")
        utils.map("n", "<leader>gH", "<cmd>DiffviewFileHistory %<cr>")
        utils.map("n", "<leader>gl", "<cmd>DiffviewFileHistory .<cr>")
    end,
    config = function()
        local actions = require("diffview/actions")

        require("diffview").setup({
            file_panel = { win_config = { position = "right" }, listing_style = "list" },
            key_bindings = {
                disable_defaults = true,
                view = {
                    ["]q"] = actions.select_next_entry,
                    ["[q"] = actions.select_prev_entry,

                    ["e"] = actions.goto_file,
                    ["<leader>gh"] = actions.toggle_files,
                },
                file_panel = {
                    ["j"] = actions.next_entry,
                    ["k"] = actions.prev_entry,
                    ["<cr>"] = actions.select_entry,

                    ["]q"] = actions.select_next_entry,
                    ["[q"] = actions.select_prev_entry,
                    ["]c"] = actions.select_next_entry,
                    ["[c"] = actions.select_prev_entry,

                    ["s"] = actions.toggle_stage_entry,
                    ["S"] = actions.stage_all,
                    ["U"] = actions.unstage_all,
                    ["X"] = actions.restore_entry,
                    ["R"] = actions.refresh_files,

                    -- merge tool
                    ['co'] = actions.conflict_choose('ours'),
                    ['ct'] = actions.conflict_choose('theirs'),
                    ['cb'] = actions.conflict_choose('base'),
                    ['ca'] = actions.conflict_choose('all'),
                    ['cX'] = actions.conflict_choose('none'),

                    ["e"] = actions.goto_file,
                    ["<leader>gh"] = actions.toggle_files,
                },
                file_history_panel = {
                    ["zr"] = actions.open_all_folds,
                    ["zm"] = actions.close_all_folds,

                    ["]q"] = actions.select_next_entry,
                    ["[q"] = actions.select_prev_entry,
                    ["]c"] = actions.select_next_entry,
                    ["[c"] = actions.select_prev_entry,

                    ["j"] = actions.next_entry,
                    ["k"] = actions.prev_entry,
                    ["<cr>"] = actions.select_entry,
                    ["="] = actions.open_in_diffview,

                    ["e"] = actions.goto_file,
                    ["<leader>gh"] = actions.toggle_files,
                },
                options_panel = {},
            },
        })
    end
}
