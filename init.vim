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
Plug 'vim-syntastic/syntastic', {'for': ['python', 'go', 'c', 'cpp', 'java']}
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'

Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'Shougo/echodoc.vim'

Plug 'deoplete-plugins/deoplete-jedi', {'for': 'python', 'do': ':UpdateRemotePlugins'}
Plug 'davidhalter/jedi-vim', {'for': 'python'}
Plug 'deoplete-plugins/deoplete-go', {'for': 'go', 'do': 'make'}
Plug 'fatih/vim-go', {'for': 'go'}
Plug 'zchee/deoplete-clang', {'for': ['c', 'cpp']}
Plug 'artur-shaik/vim-javacomplete2', {'for': 'java'}

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

set completeopt=menu,menuone,noinsert,noselect
set guifont=FiraCode-Retina:h14
set guicursor+=i:ver100-iCursor

" set wrap
set nowrap
set textwidth=79
set colorcolumn=+1
set formatoptions=qrnj1
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
set smartcase

set laststatus=2
set noshowmode
set showcmd
set omnifunc=syntaxcomplete#Complete
set clipboard^=unnamed,unnamedplus
set shortmess+=c

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

let g:syntastic_go_checkers=['gofmt']
let g:go_highlight_extra_types=1
let g:go_highlight_fields=1
let g:go_highlight_functions=1
let g:go_highlight_function_calls=1
let g:go_highlight_methods=1
let g:go_highlight_operators=1
let g:go_highlight_structs=1
let g:go_highlight_types=1

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" autopairs
let g:AutoPairs={'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`', '<':'>', '<<':''}
let g:AutoPairsMapSpace=0

" neoformat
autocmd FileType go let $PATH=$PATH.":".$GOBIN
autocmd FileType python,go,c,cpp,java noremap <buffer> <C-f> :Neoformat<CR>

" deoplete
let g:deoplete#enable_at_startup=1

" jedi
let g:jedi#completions_enabled=0
let g:jedi#show_call_signatures=0

" echodoc
let g:echodoc#enable_at_startup=1
let g:echodoc#type='floating'

" go
let g:deoplete#sources#go#gocode_binary=$GOBIN.'/gocode'
let g:deoplete#sources#go#source_importer=1
let g:deoplete#sources#go#pointer=1

let g:go_fmt_command='goimports'
let g:go_addtags_transform='snakecase'
let g:go_list_type='quickfix'

autocmd FileType go noremap <leader>d :GoDef<CR>
autocmd FileType go noremap <leader>n :GoRef<CR>
autocmd FileType go noremap <leader>k :GoDoc<CR>

" clang
let g:deoplete#sources#clang#libclang_path="/Library/Developer/CommandLineTools/usr/lib/libclang.dylib"
let g:deoplete#sources#clang#clang_header="/Library/Developer/CommandLineTools/usr/lib/clang/11.0.0/include/"
let g:deoplete#sources#clang#std={'c': 'c98'}

" javacomplete2
autocmd FileType java setlocal omnifunc=javacomplete#Complete
let g:deoplete#omni_patterns={}
let g:deoplete#omni_patterns.java='[^. *\t]\.\w*'

" polyglot
let g:polyglot_disable=['go']

" custom
nnoremap <C-w><C-l> :lclose<CR> :pclose<CR> :ccl<CR>
nnoremap <leader>t :bn<CR>
nnoremap <leader>y :bN<CR>
nnoremap <leader>q :bd<CR>

nnoremap ; :
nnoremap : ;

cmap Wq wq
cmap Q q

" : deoplete
" <leader> (go) (guru)
"         + d : goto definition
"         + n : show usages
"         + k : show documentation
" <leader> (python) (jedi)
"         + d : goto definition
"         + n : show usages
"         + r : rename
"         + k : show documentation

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
