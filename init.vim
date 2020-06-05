filetype plugin indent on

" nnoremap <space> <Nop>
" let mapleader=" "

set rtp+=~/.config/nvim
call plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar'
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-eunuch'
Plug 'junegunn/goyo.vim'
Plug 'christoomey/vim-tmux-navigator'

Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

Plug 'flazz/vim-colorschemes'
Plug 'relastle/bluewery.vim'

Plug 'scrooloose/nerdcommenter'
Plug 'vim-syntastic/syntastic', {'for': ['python', 'c', 'cpp', 'java']}
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'

Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
" Plug 'Shougo/echodoc.vim'

Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'lighttiger2505/deoplete-vim-lsp'

" Plug 'sheerun/vim-polyglot'

call plug#end()

syntax enable
syntax on

set modelines=0
set number
set ruler
set cursorline
set matchpairs+=<:>
set mouse=a

set encoding=utf-8
set history=100
set autoread
set hidden
set splitright
set splitbelow

set wildmenu

set noswapfile
set nobackup
set nowb
set lazyredraw

set visualbell
set guicursor=a:blinkon0
set termguicolors
set background=dark
colorscheme CandyPaper " bluewery anderson gotham gruvbox CandyPaper
                       " Atelier_SavannaLight Atelier_EstuaryDark

set completeopt=menu,noinsert,noselect
set guifont=FiraCode-Retina:h14
set guicursor+=i:ver100-iCursor

" set wrap
set nowrap
set linebreak
set textwidth=79
set colorcolumn=+1
set formatoptions=tcjrnq1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set noshiftround
set scrolloff=3
set backspace=2

set incsearch
set ignorecase
set nohlsearch
set smartcase

set laststatus=2
set noshowmode
set noshowcmd
set omnifunc=syntaxcomplete#Complete
set clipboard^=unnamed,unnamedplus
set shortmess+=c

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
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" nerdtree
let g:NERDTreeChDirMode=2

autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc()==0 && !exists('s:std_in') | NERDTree | endif
nnoremap <leader>j :NERDTreeToggle<CR>
nnoremap <leader>1 :NERDTreeFind<CR>

let g:NERDTreeIgnore = [
    \ '\~$',
    \ '\.pyc$',
    \ '^\.DS_Store$',
    \ '^node_modules$',
    \ '^.ropeproject$',
    \ '^__pycache__$'
\]

let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "~",
    \ "Staged"    : "+",
    \ "Untracked" : "*",
    \ "Unmerged"  : "=",
    \ "Deleted"   : "x",
    \ }

" airline
let g:airline_theme='hybrid' " bluewery deus hybrid luna base16_embers
                             " base16_3024 base16_gruvbox_dark_hard

let g:airline_solarized_bg='dark'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#fnamemode=':t'
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#formatter='unique_tail'

" tagbar
nnoremap <leader>k :TagbarToggle<CR>

" fzf
let $FZF_DEFAULT_COMMAND='rg --files'
let g:fzf_preview_window='right:60%'
let g:fzf_buffers_jump=1
nnoremap <C-p> :Files<CR>
nnoremap <leader>f :Rg<space>

" goyo
let g:goyo_height="100%"

" fugitive
set statusline+=%{FugitiveStatusline()}
set diffopt+=vertical

" syntastic
let g:python_highlight_all=1
let g:syntastic_python_python_exec='python3'
let g:syntastic_python_checkers=['flake8']

if PlugLoaded('vim-syntastic/syntastic')
    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*
endif

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 0
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0
let g:syntastic_auto_jump = 0

let g:syntastic_error_symbol = 'x'
let g:syntastic_style_error_symbol = 'x'
let g:syntastic_warning_symbol = '?'
let g:syntastic_style_warning_symbol = '?'

" autopairs
let g:AutoPairs={'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`', '<':'>', '<<':''}
let g:AutoPairsMapSpace=0
let g:AutoPairsShortcutToggle=''

" neoformat
autocmd FileType python,c,cpp,java noremap <buffer> <C-f> :Neoformat<CR>

" deoplete
let g:deoplete#enable_at_startup=1

" echodoc
" let g:echodoc#enable_at_startup=0
" let g:echodoc#type='floating'

" gitgutter
let g:gitgutter_sign_added='|'
let g:gitgutter_sign_modified='~'

" lsp and autocomplete
if executable('pyls')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd', '-background-index']},
        \ 'whitelist': ['c', 'cpp', 'objc', 'objcpp'],
        \ })
endif

" do manual install, works when project directory is formed
if executable('java') && filereadable(expand('~/.local/share/vim-lsp-settings/servers/eclipse.jdt.ls/plugins/org.eclipse.equinox.launcher_1.5.600.v20191014-2022.jar'))
    au User lsp_setup call lsp#register_server({
        \ 'name': 'eclipse.jdt.ls',
        \ 'cmd': {server_info->[
        \     'java',
        \     '-Declipse.application=org.eclipse.jdt.ls.core.id1',
        \     '-Dosgi.bundles.defaultStartLevel=4',
        \     '-Declipse.product=org.eclipse.jdt.ls.core.product',
        \     '-Dlog.level=ALL',
        \     '-noverify',
        \     '-Dfile.encoding=UTF-8',
        \     '-Xmx1G',
        \     '-jar',
        \     expand('~/.local/share/vim-lsp-settings/servers/eclipse.jdt.ls/plugins/org.eclipse.equinox.launcher_1.5.600.v20191014-2022.jar'),
        \     '-configuration',
        \     expand('~/.local/share/vim-lsp-settings/servers/eclipse.jdt.ls/config_linux'),
        \     '-data',
        \     getcwd()
        \ ]},
        \ 'whitelist': ['java'],
        \ })
endif

function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete

    nmap <buffer> <leader>d <plug>(lsp-definition)
    nmap <buffer> <leader>u <plug>(lsp-references)
    nmap <buffer> <leader>r <plug>(lsp-rename)
endfunction

augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup endif

let g:lsp_diagnostics_enabled=0
let g:lsp_signs_enabled=0

inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"

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
    let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
    let &t_SR = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=2\x7\<Esc>\\"
    let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
    let &t_SI = "\<Esc>]50;CursorShape=1\x7"
    let &t_SR = "\<Esc>]50;CursorShape=2\x7"
    let &t_EI = "\<Esc>]50;CursorShape=0\x7"
endif

hi! Normal ctermbg=NONE guibg=NONE
hi! NonText ctermbg=NONE guibg=NONE guifg=NONE ctermfg=NONE

map <ScrollWheelUp> <C-Y>
map <ScrollWheelDown> <C-E>

nnoremap <C-w><C-l> :lclose<CR> :pclose<CR> :ccl<CR>
nnoremap <leader>t :bn<CR>
nnoremap <leader>y :bN<CR>
nnoremap <leader>q :bd!<CR>

nnoremap ; :
nnoremap : ;

cmap W w
cmap Wq wq
cmap Q q

" : vim-lsp deoplete
" <leader> (python)
"         + d : goto definition
"         + u : show usages
"         + r : rename

" : gitgutter
" ]c : next hunk
" [c : previous hunk
" <leader>
"         + hs : stage hunk
"         + hu : unstage hunk

" : nerd commenter
" <leader>c<space> : toggle comment

" : multiple cursors
" <C-n> : cursor select next
" <C-x> : cursor skip next
" <C-p> : cursor previous

" : goyo
" :Goyo : toggle goyo mode

" :GV       : Fugitive commit graph
" <leader>s : vsp term://shell : split terminal
" <leader>1 : NERDTreeFind
