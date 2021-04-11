filetype plugin indent on

set rtp+=~/.config/nvim
call plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

Plug 'godlygeek/tabular'
Plug 'tpope/vim-eunuch'
Plug 'christoomey/vim-tmux-navigator'
Plug 'airblade/vim-rooter'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

Plug 'flazz/vim-colorschemes'
Plug 'relastle/bluewery.vim'
Plug 'morhetz/gruvbox'

Plug 'pacha/vem-tabline'

Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'

Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'autozimu/LanguageClient-neovim', {'branch': 'next','do': 'bash install.sh'}
Plug 'Shougo/neoinclude.vim'
Plug 'Shougo/echodoc.vim'

call plug#end()

syntax enable " allow over-riding

set nonumber
set signcolumn=yes
set cursorline
set mouse=a
set modelines=0
set matchpairs+=<:>
"set numberwidth=5

set history=100
set hidden
set splitright
set splitbelow
set exrc
set secure

set noswapfile
set nobackup
set autowrite
set nowb
set undofile
set undodir=~/.config/undodir

set lazyredraw
set visualbell
set termguicolors

set nowrap
set textwidth=79
set colorcolumn=+1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set smarttab
set autoindent
set noshiftround
set scrolloff=3
set backspace=2
set autoread

set nohlsearch
set incsearch
set ignorecase
set smartcase

set laststatus=2
set noshowmode
set noshowcmd
set clipboard^=unnamed,unnamedplus
set shortmess+=c
set omnifunc=syntaxcomplete#Complete
set display+=lastline
set title

" set nofoldenable
set foldmethod=manual
set completeopt=menu,noinsert,noselect,menuone
set formatoptions=cnjlr " c: comments autowrap using textwidth
                        " n: numbered lists autoindent
                        " j: autoremove comment leader when joining lines
                        " l: no auto break
                        " r: autoinsert comment leader

" colors
set background=dark

let g:gruvbox_contrast_dark='medium' " hard medium soft
let g:gruvbox_contrast_light='hard' " hard medium soft
let g:gruvbox_italic=1

colorscheme aquamarine " gruvbox deus
               " nord OceanicNext quantum neodark
               " bluewery Tomorrow-Night-Blue
               " arcadia hybrid Tomorrow-Night-Eighties mod8 evokai
               " apprentice PaperColor luna CandyPaper jellybeans default
               " materialtheme materialbox peaksea
               " antares afterglow codedark desertink lucid slate af
               " aquamarine oceanblack thor jellyx candycode murphy Dim ir_black

               " cake16 solarized8_light_high
               " Tomorrow eclipse autumnleaf aurora White2

let g:loaded_node_provider=0
let g:loaded_python_provider=0
let g:python3_host_prog='/usr/local/bin/python3'

"set guifont=FiraCode-Retina:h14
"set guicursor+=i:ver100-iCursor

" custom functions
function! RandomColors()
    colorscheme random
    colorscheme
endfunction
nnoremap <leader>e :call RandomColors()<CR>

function! <SID>StripTrailingWhitespaces()
    let l=line(".")
    let c=col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces() " strip trailing
" autocmd BufWritePre * :retab " tab to spaces

" statusline
function! GitPaddedBranch()
    let l:branchname = fugitive#head()
    return strlen(l:branchname) > 0?'   '.l:branchname.' ':''
endfunction

function! GitPaddedStatus()
  let l:branchname = fugitive#head()
  let [a,m,r] = GitGutterGetHunkSummary()
  return strlen(l:branchname) > 0? printf('| +%d ~%d -%d  ', a, m, r):''
endfunction

function! PaddedModeName()
    let l:paste_status = &paste
    if l:paste_status == 1
        return '  [PASTE] '
    else
        return '  '.toupper(get(g:mode_labels, mode(), mode())).' '
    endif
endfunction

let g:mode_labels = {
      \    'n': 'Normal', 'i': 'Insert', 'R': 'Replace', 'v': 'Visual', 'V': 'V-Line', "\<C-v>": 'V-Block',
      \    'c': 'Command', 's': 'Select', 'S': 'S-Line', "\<C-s>": 'S-Block', 't': 'Terminal'
      \}

set statusline=
set statusline+=%#PmenuSel#
set statusline+=%{PaddedModeName()}
set statusline+=%#Pmenu#
set statusline+=%{GitPaddedBranch()}
set statusline+=%{GitPaddedStatus()}
set statusline+=%#CursorLine#
set statusline+=\ %f
set statusline+=%=
set statusline+=\ %l:%c
set statusline+=\ %p%%
set statusline+=\ %#LineNr#

" nerdtree
let g:NERDTreeChDirMode=2
let g:NERDTreeDirArrowExpandable='$'
let g:NERDTreeDirArrowCollapsible='-'
let g:NERDTreeMinimalUI=1

nnoremap <leader>j :NERDTreeToggle<CR>
nnoremap <leader>1 :NERDTreeFind<CR>

let g:NERDTreeIgnore=[
    \ '\~$',
    \ '\.pyc$',
    \ '^\.DS_Store$',
    \ '^node_modules$',
    \ '^.ropeproject$',
    \ '^__pycache__$',
    \ '^venv$'
\]

let g:NERDTreeGitStatusIndicatorMapCustom={
    \ "Modified"  : "~",
    \ "Dirty"     : "~",
    \ "Staged"    : "+",
    \ "Untracked" : "*",
    \ "Unmerged"  : "=",
    \ "Deleted"   : "x",
    \ "Clean"     : ""
    \ }

" tagbar
let g:tagbar_autofocus=1
let g:tagbar_iconchars=['$', '-']
nnoremap <leader>k :TagbarToggle<CR>

" vem tabline
set showtabline=1
let g:vem_tabline_show=1
let g:vem_tabline_show_number="buffnr"

" tabular
vnoremap <leader>= :Tab /

" fzf
let g:fzf_preview_window='right:50%'
let g:fzf_buffers_jump=1
let g:fzf_layout={'down': '40%'}

set grepprg=rg\ --no-heading\ --vimgrep
set grepformat=%f:%l:%c:%m

autocmd! FileType fzf set laststatus=0 noshowmode noruler | autocmd BufLeave <buffer> set laststatus=2 showmode ruler

nnoremap <C-p> :Files<CR>
nnoremap <leader>f :Rg<CR>
nnoremap <leader>z :Rg TODO<CR>

" fugitive
set diffopt+=vertical

" nerd commenter
let g:NERDCreateDefaultMappings=0
map <leader>c<space> <plug>NERDCommenterToggle

" autopairs
let g:AutoPairs={'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`', '<':'>', '<<':''}
let g:AutoPairsMapSpace=0
let g:AutoPairsMultilineClose=0
let g:AutoPairsShortcutToggle=''
let g:AutoPairsShortcutFastWrap='<c-w>'

" neoformat
autocmd FileType python,c,cpp noremap <buffer> <C-f> :Neoformat<CR>

" gitgutter
let g:gitgutter_sign_added='|'
let g:gitgutter_sign_modified='~'
let g:gitgutter_sign_removed='-'
let g:gitgutter_use_location_list=1
autocmd BufWritePost * silent! :GitGutter
autocmd BufEnter * silent! :GitGutter

let g:gitgutter_map_keys=0
nmap <leader>hs <plug>(GitGutterStageHunk)
nmap <leader>hu <plug>(GitGutterUndoHunk)
nmap <leader>hp <plug>(GitGutterPreviewHunk)
nmap ]c         <plug>(GitGutterNextHunk)
nmap [c         <plug>(GitGutterPrevHunk)

" deoplete
let g:deoplete#enable_at_startup=1
call deoplete#custom#source('_', 'matchers', ['matcher_fuzzy', 'matcher_length'])
call deoplete#custom#option({'ignore_case': v:true})

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
autocmd InsertLeave,CompleteDone * silent! pclose!

" echodoc
let g:echodoc#enable_at_startup=1
let g:echodoc#type='popup'
highlight link EchoDocPopup Pmenu

" languageclient neovim
set completefunc=LanguageClient#complete

let g:LanguageClient_loggingLevel = 'DEBUG'
let g:LanguageClient_loggingFile  = expand('~/.local/share/nvim/LanguageClient.log')
let g:LanguageClient_serverStderr = expand('~/.local/share/nvim/LanguageServer.log')

let g:LanguageClient_diagnosticsDisplay={
 \         1: {
 \             "name": "Error",
 \             "signText": "x",
 \             "signTexthl": "",
 \             "virtualTexthl": "",
 \             "texthl": "",
 \         },
 \         2: {
 \             "name": "Warning",
 \             "signText": "!",
 \             "signTexthl": "",
 \             "virtualTexthl": "",
 \             "texthl": "",
 \         },
 \         3: {
 \             "name": "Information",
 \             "signText": "i",
 \             "signTexthl": "",
 \             "virtualTexthl": "",
 \             "texthl": "",
 \         },
 \         4: {
 \             "name": "Hint",
 \             "signText": "h",
 \             "signTexthl": "",
 \             "virtualTexthl": "",
 \             "texthl": "",
 \         },
 \     }

let g:LanguageClient_changeThrottle=0.5
let g:LanguageClient_settingsPath='.lsconf.json'
let g:LanguageClient_diagnosticsList='Location'

let g:LanguageClient_showCompletionDocs=0
let g:LanguageClient_useFloatingHover=0
let g:LanguageClient_useVirtualText='No'

let g:LanguageClient_serverCommands={
    \ 'python' : ['pyls'],
    \ 'cpp'    : ['clangd'],
    \ 'c'      : ['clangd']
    \ }

highlight link LC_ERROR Pmenu
function! LSPKeyBinds()
    nnoremap <buffer> <silent> <leader>d :call LanguageClient#textDocument_definition()<CR>
    nnoremap <buffer> <silent> <leader>u :call LanguageClient#textDocument_references()<CR>
    nnoremap <buffer> <silent> <leader>r :call LanguageClient#textDocument_rename()<CR>
    nnoremap <buffer> <silent> <a-cr> :call LanguageClient_contextMenu()<CR>
endfunction()

augroup LSP
    autocmd!
    autocmd FileType python,cpp,c call LSPKeyBinds()
    autocmd FileType python,cpp,c set signcolumn=yes
augroup END

call deoplete#custom#source('LanguageClient', 'min_pattern_length', 2)

" other settings
if executable('fish')
    set shell=fish
    nnoremap <leader>s :vsp term://fish<CR>
elseif executable('zsh')
    set shell=zsh
    nnoremap <leader>s :vsp term://zsh<CR>
else
    set shell=sh
    nnoremap <leader>s :vsp term://sh<CR>
endif

" seamless terminal navigation
tnoremap <ESC> <C-\><C-n>
tnoremap <c-h> <C-\><C-N><C-w>h
tnoremap <c-j> <C-\><C-N><C-w>j
tnoremap <c-k> <C-\><C-N><C-w>k
tnoremap <c-l> <C-\><C-N><C-w>l

if exists("tmux")
    let &t_SI="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_SR="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
    let &t_EI="\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI="\<Esc>]50;CursorShape=1\x7"
    let &t_SR="\<Esc>]50;CursorShape=2\x7"
    let &t_EI="\<Esc>]50;CursorShape=0\x7"
endif

" help with transparent backgrounds
"hi! Normal ctermbg=NONE guibg=NONE
"hi! NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE

" make comments bolditalic
highlight Comment cterm=bolditalic gui=bolditalic

" make signcolumn prettier
"autocmd ColorScheme * highlight! link SignColumn LineNr
autocmd BufEnter,ColorScheme * highlight clear SignColumn

command! Errors execute "lopen"
au! BufWritePost $MYVIMRC source %

map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

" disable arrow keys
nmap <up> <nop>
nmap <down> <nop>
nmap <left> <nop>
nmap <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

nnoremap <m-j> :resize +2<CR>
nnoremap <m-k> :resize -2<CR>
nnoremap <m-h> :vertical resize -2<CR>
nnoremap <m-l> :vertical resize +2<CR>

" utility
nnoremap <C-w><C-l> :lclose<CR> :pclose<CR> :ccl<CR>
nnoremap <leader>t :bn<CR>
nnoremap <leader>y :bN<CR>
nnoremap <leader>q :bd!<CR>

vnoremap < <gv
vnoremap > >gv

nnoremap <space> za
nnoremap <leader>2 <C-w>o

nnoremap ; :
nnoremap : ;

map H ^
map L $

inoremap jj <esc>

" fix common typos
cmap Wq wq
cmap Q q

" : deoplete languageclient neovim
" <leader>
"         + d : goto definition
"         + u : show usages
"         + r : rename
" <alt-enter> : context menu

" :GV       : Commit graph
" <leader>s : vsp term://shell : split terminal
" <leader>1 : NERDTreeFind
" <leader>= : tabular
" :Errors   : Error list

" <leader>3 : AutoHighlightToggle

" <c-w> v             : vsplit
" <c-w> s             : hsplit
" <c-w>HLJK           : move current split
" <c-w> o | <leader>2 : maximize current buffer

" see colors :so $VIMRUNTIME/syntax/hitest.vim

" project setup
"       .nvimrc       : nvim setup like venv
"       .lsconf.json  : language server configs
"       setup.cfg     : flake8, pep8 etc setup
"       .rgignore     : ripgrep ignore

" autopep8 formatting -> setup.cfg under [flake8]

" custom functions
nnoremap <leader>3 :if AutoHighlightToggle()<Bar>set hls<Bar>endif<CR>
function! AutoHighlightToggle()
  let @/ = ''
  if exists('#auto_highlight')
    au! auto_highlight
    augroup! auto_highlight
    setl updatetime=5000
    echo 'Highlight current word: off'
    set nohlsearch
    return 0
  else
    augroup auto_highlight
      au!
      au CursorHold * let @/ = '\V\<'.escape(expand('<cword>'), '\').'\>'
    augroup end
    setl updatetime=500
    echo 'Highlight current word: ON'
    return 1
  endif
endfunction
