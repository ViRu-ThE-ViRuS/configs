syntax enable
filetype plugin indent on

set rtp+=~/.config/nvim
call plug#begin('~/.config/nvim/plugged')

Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'airblade/vim-gitgutter'
Plug 'majutsushi/tagbar'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'tpope/vim-fugitive'

Plug 'flazz/vim-colorschemes'

Plug 'vim-syntastic/syntastic'
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'Shougo/echodoc.vim'

Plug 'deoplete-plugins/deoplete-go', {'for': 'go', 'do': 'make'}
Plug 'fatih/vim-go', {'for': 'go', 'do': ':GoUpdateBinaries'}

Plug 'deoplete-plugins/deoplete-jedi', {'for': 'python', 'do': ':UpdateRemotePlugins'}
Plug 'davidhalter/jedi-vim', {'for': 'python'}

Plug 'sheerun/vim-polyglot'

call plug#end()

set modelines=0
set number
set ruler
set cursorline
set matchpairs+=<:>
set mouse=incr

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
colorscheme pencil

set completeopt=menu,menuone,noinsert,noselect
set guifont=FiraCode-Retina:h14

set wrap
set textwidth=79
set colorcolumn=+1
set formatoptions=tcqrn1
set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
set autoindent
set noshiftround
set scrolloff=3
set backspace=indent,eol,start

set incsearch
set ignorecase
set nohlsearch

set laststatus=2
set showmode
set showcmd

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
nmap <C-n> :NERDTreeToggle<CR>

let g:NERDTreeIgnore = [
    \ '\~$',
    \ '\.pyc$',
    \ '^\.DS_Store$',
    \ '^node_modules$',
    \ '^.ropeproject$',
    \ '^__pycache__$'
\]

" airline
let g:airline_theme='luna'
let g:airline_solarized_bg='dark'
let g:airline#extensions#tabline#enabled=1
let g:airline#extensions#tabline#fnamemode=':t'
let g:airline#extensions#tabline#buffer_nr_show = 1

" tagbar
nmap <C-j> :TagbarToggle<CR>

" ctrlp
let g:ctrlp_map='<C-p>'
let g:ctrlp_working_path_mode='ra'
let g:ctrlp_custom_ignore='node_modules\|DS_Store\|git\|venv'
let g:ctrlp_show_hidden=1

" fugitive
set statusline+=%{FugitiveStatusline()}

" syntastic
let g:python_highlight_all=1
let g:syntastic_python_python_exec='python3'
let g:syntastic_python_checkers=['flake8']

let g:go_highlight_all=1
let g:syntastic_go_checkers=['gofmt']

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
autocmd FileType python,go noremap <buffer> <C-f> :Neoformat<CR>

" deoplete
let g:deoplete#enable_at_startup=1

" echodoc
let g:echodoc#enable_at_startup=1
let g:echodoc#type = 'floating'

" go
let g:deoplete#sources#go#source_importer=1
let g:deoplete#sources#go#pointer=1

let g:go_fmt_command='goimports'
let g:go_addtags_transform='snakecase'
let g:go_highlight_sameids=1
let g:go_list_type='quickfix'

autocmd FileType go nmap <leader>d :GoDef<CR>
autocmd FileType go nmap <leader>n :GoRef<CR>

" jedi
let g:jedi#completions_enabled = 0

" custom
nmap <C-w><C-l> :lclose<CR> :pclose<CR> :ccl<CR>
nmap <leader>t :bn<CR>
nmap <leader>y :bN<CR>
nmap <leader>d :bd<CR>


" : ctrlp
"       C-y : create file

" : deoplete
" <leader> (go) (guru)
"         + d : goto definition
"         + n : show usages
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

