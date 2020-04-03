filetype plugin indent on

set rtp+=~/.config/nvim
call plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'majutsushi/tagbar'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'terryma/vim-multiple-cursors'
Plug 'tpope/vim-eunuch'
Plug 'junegunn/goyo.vim'

Plug 'flazz/vim-colorschemes'
Plug 'relastle/bluewery.vim'

Plug 'scrooloose/nerdcommenter'
Plug 'vim-syntastic/syntastic', {'for': ['python', 'c', 'cpp', 'java']}
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'

Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'Shougo/echodoc.vim'

Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'
Plug 'lighttiger2505/deoplete-vim-lsp'

Plug 'sheerun/vim-polyglot'

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

set noswapfile
set nobackup
set nowb

set visualbell
set gcr=a:blinkon0
set termguicolors
set background=dark
colorscheme gruvbox " bluewery anderson gotham gruvbox

set completeopt=menu,menuone,noinsert
set guifont=FiraCode-Retina:h14
set guicursor+=i:ver100-iCursor

" set wrap
set nowrap
set textwidth=79
set colorcolumn=+1
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set autoindent
set noshiftround
set scrolloff=3
set backspace=indent,eol,start

set incsearch
set ignorecase
set nohlsearch

set laststatus=2
set noshowmode
set showcmd
set omnifunc=syntaxcomplete#Complete

let g:python3_host_prog='/usr/bin/python3'

" trim trailing whitespaces
function! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc()==0 && !exists('s:std_in') | NERDTree | endif
nnoremap <C-h> :NERDTreeToggle<CR>

let g:NERDTreeIgnore = [
    \ '\~$',
    \ '\.pyc$',
    \ '^\.DS_Store$',
    \ '^node_modules$',
    \ '^.ropeproject$',
    \ '^__pycache__$'
\]

" airline
let g:airline_theme='base16_embers' " bluewery deus hybrid luna base16_embers
let g:airline_solarized_bg='dark'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#fnamemode=':t'
let g:airline#extensions#tabline#buffer_nr_show = 1

" tagbar
nnoremap <C-j> :TagbarToggle<CR>

" ctrlp
let g:ctrlp_map='<C-p>'
let g:ctrlp_working_path_mode='ra'
let g:ctrlp_custom_ignore='node_modules\|DS_Store\|git\|venv'
let g:ctrlp_show_hidden=1

" goyo
let g:goyo_height="100%"

" fugitive
set statusline+=%{FugitiveStatusline()}
set diffopt+=vertical

" syntastic
let g:python_highlight_all=1
let g:syntastic_python_python_exec='python3'
let g:syntastic_python_checkers=['flake8']

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" autopairs
let g:AutoPairs={'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`', '<':'>', '<<':''}

" neoformat
autocmd FileType python,c,cpp,java noremap <buffer> <C-f> :Neoformat<CR>

" deoplete
let g:deoplete#enable_at_startup=1

" echodoc
let g:echodoc#enable_at_startup=1
let g:echodoc#type='floating'

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

" custom
nnoremap <C-w><C-l> :lclose<CR> :pclose<CR> :ccl<CR>
nnoremap <leader>t :bn<CR>
nnoremap <leader>y :bN<CR>
nnoremap <leader>q :bd<CR>

nnoremap ; :
nnoremap : ;

" vim-lsp
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
" <leader>
"         + cc : comment
"         + cu : uncomment

" : multiple cursors
" <C-n> : cursor select next
" <C-x> : cursor skip next
" <C-p> : cursor previous

" : goyo
" :Goyo : toggle goyo mode

" <C-v> : visual block mode
