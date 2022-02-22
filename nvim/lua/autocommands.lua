vim.cmd [[
    " some colorschemes be weird
    " highlight! link FloatBorder Pmenu
    " highlight! link LspFloatWinBorder LspFloatWinNormal

    augroup Misc
        autocmd!
        autocmd TextYankPost * lua vim.highlight.on_yank {on_visual = false}
        autocmd BufWritePre * lua require('utils').strip_trailing_whitespaces()

        autocmd FileType qf nnoremap <buffer> <c-v> <c-w><cr><c-w>L
        autocmd FileType qf nnoremap <buffer> <c-x> <c-w><cr><c-w>H
    augroup end

    augroup ConfigUpdate
        autocmd!
        autocmd BufWritePost ~/.config/nvim/init.lua source <afile>
        autocmd BufWritePost ~/.config/nvim/lua/*.lua source <afile>
    augroup end

    augroup UISetup
        autocmd!
        autocmd BufEnter,ColorScheme * highlight Comment cterm=bold,italic gui=bold,italic
        autocmd BufEnter,ColorScheme * highlight LineNr ctermbg=NONE guibg=NONE
        autocmd BufEnter,ColorScheme * highlight SignColumn ctermbg=NONE guibg=NONE
    augroup end

    augroup TerminalSetup
        autocmd!
        autocmd TermOpen * setlocal filetype=terminal
        autocmd TermOpen * setlocal nonumber
    augroup end

    " NOTE(vir): now using nvim-notify
    function! AutoHighlightToggle()
      let @/ = ''
      if exists('#auto_highlight')
        autocmd! auto_highlight
        augroup! auto_highlight
        setl updatetime=5000

        " echo 'highlight current word: off'
        lua require('notify')('highlight current word: OFF', 'info', { timeout = 250, render = 'minimal' })

        return 0
      else
        augroup auto_highlight
          autocmd!
          autocmd CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
        augroup end
        setl updatetime=500

        " echo 'highlight current word: on'
        lua require('notify')('highlight current word: ON', 'info', { timeout = 250, render = 'minimal' })

        return 1
      endif
    endfunction
]]

