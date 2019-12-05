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

Plug 'altercation/vim-colors-solarized'
Plug 'flazz/vim-colorschemes'

Plug 'vim-syntastic/syntastic'
Plug 'jiangmiao/auto-pairs'
Plug 'sbdchd/neoformat'
Plug 'Shougo/deoplete.nvim', {'do': ':UpdateRemotePlugins'}
Plug 'Shougo/echodoc.vim'

Plug 'deoplete-plugins/deoplete-jedi', {'for': 'python', 'do': ':UpdateRemotePlugins'}
Plug 'davidhalter/jedi-vim', {'for': 'python'}

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
colorscheme OceanicNext

set completeopt=menu,menuone,noinsert
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

" nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc()==0 && !exists('s:std_in') | NERDTree | endif
map <C-n> :NERDTreeToggle<CR>

" airline
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'

" tagbar
map <C-j> :TagbarToggle<CR>

" ctrlp
let g:ctrlp_map='<C-p>'
let g:ctrlp_working_path_mode='ra'

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
autocmd FileType python noremap <buffer> <C-f> :Neoformat<CR>

" deoplete
let g:deoplete#enable_at_startup=1

" echodoc
let g:echodoc#enable_at_startup=1
let g:echodoc#type = 'floating'

" jedi
let g:jedi#completions_enabled = 0

" custom
map <C-w><C-l> :lclose<CR>

" C-v : ctrlp open in vsplit
" C-h : ctrlp open in hsplit
" C-o : return to prev buffer
" C-w + z : close scratch buffer
" C-w + C-l : lclose

" <leader> : jedi
"          + d : goto definition
"          + g : goto assignment
"          + n : show usages
"          + r : rename
"          + k : show documentation

" C-b : tmux super
"     + d : detach session
"     + % : split vertically
"     + " : split horizontally

