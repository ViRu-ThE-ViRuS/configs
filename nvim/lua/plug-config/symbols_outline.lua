-- buggy
local utils = require('utils')

vim.g.symbols_outline = {
    highlight_hovered_item = true,
    show_guides = true,
    auto_preview = false,
    position = 'right',
    keymaps = nil
}

utils.map('n', '<leader>k', '<cmd>SymbolsOutline<cr>')

vim.cmd [[
function! SymbolOutlineKeymaps()
    nnoremap <buffer> <silent> <esc> :bw!<cr>
    nnoremap <buffer> <silent> <cr> :lua require('symbols-outline')._goto_location(true)<cr>
    nnoremap <buffer> <silent> o :lua require('symbols-outline')._goto_location(false)<cr>
endfunction()

augroup SymbolsOutline
    autocmd!
    autocmd FileType Outline call SymbolOutlineKeymaps()
augroup END
]]
