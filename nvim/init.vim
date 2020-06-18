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
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-eunuch'
Plug 'christoomey/vim-tmux-navigator'

Plug 'airblade/vim-rooter'
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'flazz/vim-colorschemes'
Plug 'relastle/bluewery.vim'
Plug 'morhetz/gruvbox'

Plug 'scrooloose/nerdcommenter'
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'autozimu/LanguageClient-neovim', {'branch': 'next','do': 'bash install.sh'}
Plug 'Shougo/neoinclude.vim'
Plug 'Shougo/echodoc.vim'

call plug#end()

syntax on

set modelines=0
set number
set cursorline
set matchpairs+=<:>
set mouse=a

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
set background=dark
colorscheme gruvbox " bluewery anderson gruvbox CandyPaper
                    " deus zenburn nord neodark northpole nordisk
                    " solarized8_dark_high Tomorrow-Night-Blue
                    " thor jelleybeans

let g:gruvbox_contrast_dark='medium'
let g:airline_solarized_bg='dark'

set completeopt=menu,noinsert,noselect
set guifont=FiraCode-Retina:h14
set guicursor+=i:ver100-iCursor
set formatoptions=crlnj " t: textwidth
                        " c: comments wrap
                        " r: comment leader
                        " n: numbered lists
                        " l: no auto break
                        " j: remove comment leader when joining lines

set nowrap
set textwidth=79
set colorcolumn=+1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set noshiftround
set scrolloff=3
set backspace=2

set nohlsearch
set incsearch
set ignorecase
set smartcase

set laststatus=2
set noshowmode
set noshowcmd
set omnifunc=syntaxcomplete#Complete
set clipboard^=unnamed,unnamedplus
set shortmess+=c
set signcolumn=yes

let g:python3_host_prog='/usr/bin/python3'

" custom functions
function! PlugLoaded(name)
    return (
        \ has_key(g:plugs, a:name) &&
        \ isdirectory(g:plugs[a:name].dir) &&
        \ stridx(&rtp, g:plugs[a:name].dir) >= 0)
endfunction

function! RandomLook()
    colorscheme random
    " AirlineTheme random
    colorscheme
endfunction
nnoremap <leader>e :call RandomLook()<CR>

" trim trailing whitespaces
function! <SID>StripTrailingWhitespaces()
    let l=line(".")
    let c=col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" nerdtree
let g:NERDTreeChDirMode=2
let g:NERDTreeDirArrowExpandable='$'
let g:NERDTreeDirArrowCollapsible='-'

if PlugLoaded('scrooloose/nerdtree')
    autocmd StdinReadPre * let s:std_in=1
    autocmd VimEnter * if argc()==0 && !exists('s:std_in') | NERDTree | endif
endif

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

let g:NERDTreeIndicatorMapCustom={
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

" airline
let g:airline_theme='gruvbox' " bluewery deus hybrid luna base16_ashes
                              " gruvbox monochrome
                              " jelleybeans

let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#fnamemode=':t'
let g:airline#extensions#tabline#buffer_nr_show=1
let g:airline#extensions#tabline#formatter='unique_tail'

" tabular
vnoremap <leader>= :Tab /

" fzf
let $FZF_DEFAULT_COMMAND='rg --files --hidden --follow'
let g:fzf_preview_window='right:50%'
let g:fzf_buffers_jump=1

nnoremap <C-p> :Files<CR>
nnoremap <leader>f :Rg<CR>

set grepprg=rg\ --no-heading\ --vimgrep
set grepformat=%f:%l:%c:%m

" fugitive
if PlugLoaded('tpope/vim-fugitive')
    set statusline+=%{FugitiveStatusline()}
endif
set diffopt+=vertical

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
autocmd BufWritePost * silent! :GitGutter

" deoplete
let g:deoplete#enable_at_startup=1
call deoplete#custom#source('_', 'matchers', ['matcher_fuzzy', 'matcher_length'])
call deoplete#custom#option({'ignore_case': v:true})

inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
autocmd InsertLeave,CompleteDone * silent! pclose!

" echodoc
let g:echodoc#enable_at_startup=1
let g:echodoc#type='floating'
highlight link EchoDocFloat Pmenu

" languageclient neovim
set completefunc=LanguageClient#complete
command! Errors execute "lopen"

let g:LanguageClient_changeThrottle=0.5
let g:LanguageClient_useVirtualText='No'
let g:LanguageClient_settingsPath='.lsconf.json'
let g:LanguageClient_diagnosticsList='Location'
let g:LanguageClient_diagnosticsDisplay={
  \       '1': {
  \           'name'          : 'Error',
  \           'texthl'        : 'Error',
  \           'signText'      : 'x',
  \           'signTexthl'    : 'LC_ERROR',
  \           'virtualTexthl' : 'LC_ERROR',
  \       },
  \       '2': {
  \           'name'          : 'Warning',
  \           'texthl'        : 'Warning',
  \           'signText'      : '!',
  \           'signTexthl'    : 'LC_ERROR',
  \           'virtualTexthl' : 'LC_ERROR',
  \       },
  \       '3': {
  \           'name'          : 'Information',
  \           'texthl'        : 'Info',
  \           'signText'      : 'i',
  \           'signTexthl'    : 'LC_ERROR',
  \           'virtualTexthl' : 'LC_ERROR',
  \       },
  \       '4': {
  \           'name'          : 'Hint',
  \           'texthl'        : 'Info',
  \           'signText'      : 'h',
  \           'signTexthl'    : 'LC_ERROR',
  \           'virtualTexthl' : 'LC_ERROR',
  \       },
  \  }

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
augroup END

call deoplete#custom#source('LanguageClient', 'min_pattern_length', 2)

" custom
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
tnoremap <ESC> <C-\><C-n>

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

au! BufWritePost $MYVIMRC source %

map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

vnoremap < <gv
vnoremap > >gv

map H ^
map L $

nnoremap <up> <nop>
nnoremap <down> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>

nnoremap <m-j> :resize +2<CR>
nnoremap <m-k> :resize -2<CR>
nnoremap <m-h> :vertical resize -2<CR>
nnoremap <m-l> :vertical resize +2<CR>

nnoremap <C-w><C-l> :lclose<CR> :pclose<CR> :ccl<CR>
nnoremap <leader>t :bn<CR>
nnoremap <leader>y :bN<CR>
nnoremap <leader>q :bd!<CR>

nnoremap ; :
nnoremap : ;

cmap Wq wq
cmap Q q

" : deoplete languageclient neovim
" <leader>
"         + d : goto definition
"         + u : show usages
"         + r : rename
" <alt-enter> : context menu

" : multiple cursors
" <C-n> : cursor select next
" <C-x> : cursor skip next
" <C-p> : cursor previous

" :GV       : Fugitive commit graph
" <leader>s : vsp term://shell : split terminal
" <leader>1 : NERDTreeFind
" <leader>= : tabular menu

" <c-k> <c-w>H : horizontal to vertical split
" <c-h> <c-w>K : vertical to horizontal split
