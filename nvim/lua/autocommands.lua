-- TODO(vir): setup autocommands via lua api
local symbol_config = require('utils').symbol_config

Cmdline_diagnostics = function ()
    local line_diagnostics = vim.lsp.diagnostic.get_line_diagnostics()
    local line_diagnostic = line_diagnostics[#line_diagnostics]

    if line_diagnostic then
        local message = line_diagnostic.message
        local severity_level = line_diagnostic.severity

        local severity = 'seperator'
        if severity_level == 4 then severity = 'hint'
        elseif severity_level == 3 then severity = 'info'
        elseif severity_level == 2 then severity = 'warning'
        elseif severity_level == 1 then severity = 'error' end

        print(symbol_config['indicator_' .. severity] .. ': ' .. message)
    end
end

vim.cmd [[
autocmd! TextYankPost * lua vim.highlight.on_yank {on_visual = false}
autocmd! BufWritePre * lua require('utils').StripTrailingWhitespaces()

autocmd! BufWritePost ~/.config/nvim/init.lua luafile $MYVIMRC
autocmd! BufWritePost ~/.config/nvim/lua/*.lua luafile %

autocmd! CursorHold,CursorHoldI * lua Cmdline_diagnostics()
autocmd! CursorMoved,CursorMovedI * echo ''

augroup ColorsUpdate
    autocmd!
    autocmd BufEnter,ColorScheme * highlight Comment cterm=bold,italic gui=bold,italic
    autocmd BufEnter,ColorScheme * highlight clear SignColumn
    autocmd BufEnter,ColorScheme * highlight link SignColumn LineNr
augroup END

function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    autocmd! auto_highlight
    augroup! auto_highlight
    setl updatetime=5000
    echo 'Highlight current word: off'
    set nohlsearch
    return 0
  else
    augroup auto_highlight
      autocmd!
      autocmd CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction
]]

