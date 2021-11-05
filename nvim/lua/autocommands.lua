vim.cmd [[
    highlight! link FloatBorder Pmenu

    augroup Misc
        autocmd!
        autocmd TextYankPost * lua vim.highlight.on_yank {on_visual = false}
        autocmd BufWritePre * lua require('utils').strip_trailing_whitespaces()
    augroup END

    augroup ConfigUpdate
        autocmd!
        autocmd BufWritePost ~/.config/nvim/init.lua source <afile>
        autocmd BufWritePost ~/.config/nvim/lua/*.lua source <afile>
    augroup END

    augroup UISetup
        autocmd!
        autocmd BufEnter,ColorScheme * highlight Comment cterm=bold,italic gui=bold,italic
        autocmd BufEnter,ColorScheme * highlight LineNr ctermbg=NONE guibg=NONE
        autocmd BufEnter,ColorScheme * highlight SignColumn ctermbg=NONE guibg=NONE
    augroup END

    augroup TerminalSetup
        autocmd!
        autocmd TermOpen * setlocal filetype=terminal
        autocmd TermOpen * setlocal nonumber
    augroup end

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
