-- TODO(vir): fix bugs in live_grep
local utils = require('utils')

require('telescope').setup{
  defaults = {
    prompt_position = "bottom",
    prompt_prefix = "-> ",
    selection_caret = "-> ",
    layout_strategy = "horizontal",
    file_ignore_patterns = {'.DS_Store', '.cache/.*', 'venv/.*', '.git/.*'},
    preview_cutoff = 80,

    mappings = {
        n = { ['q'] = require('telescope.actions').close }
    },

    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case',
      '--hidden',
      '--no-ignore',
      '--follow'
    }
  }
}

Hybrid_find_files = function()
    local args = {
        hidden = true,
        follow = true
    }

    if utils.is_htruncated(120) then
        return require('telescope.builtin').find_files(require('telescope.themes').get_dropdown(args))
    else
        return require('telescope.builtin').find_files(args)
    end
end

Hybrid_live_grep = function()
    if utils.is_htruncated(120) then
        return require('telescope.builtin').live_grep(require('telescope.themes').get_dropdown({}))
    else
        return require('telescope.builtin').live_grep({})
    end
end

Hybrid_grep = function(todo)
    local args = {}
    if todo then
        args.prompt_title = '<TODO>'
        args.search = 'TODO|todo'
    else
        args.prompt_title = '"' .. vim.fn.expand('<cword>') .. '"'
        args.search = vim.fn.expand('<cword>')
    end

    if utils.is_htruncated(120) then
        return require('telescope.builtin').grep_string(require('telescope.themes').get_dropdown(args))
    else
        return require('telescope.builtin').grep_string(args)
    end
end

utils.map('n', '<c-p>', '<cmd>lua Hybrid_find_files()<cr>')
utils.map('n', '<leader>f', '<cmd>lua Hybrid_live_grep()<cr>')
utils.map('n', '<leader>z', '<cmd>lua Hybrid_grep(true)<cr>')
utils.map('n', '<leader>F', '<cmd>lua Hybrid_grep()<cr>')

