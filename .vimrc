set nocompatible
syntax on
filetype off
filetype plugin indent on

set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'scrooloose/nerdtree'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'
Plugin 'airblade/vim-gitgutter'
Plugin 'altercation/vim-colors-solarized'
Plugin 'flazz/vim-colorschemes'
Plugin 'majutsushi/tagbar'
Plugin 'ctrlpvim/ctrlp.vim'
Plugin 'vim-syntastic/syntastic'

Plugin 'jiangmiao/auto-pairs'
Plugin 'Valloric/YouCompleteMe'

Plugin 'Chiel92/vim-autoformat'
Plugin 'nvie/vim-flake8'

call vundle#end()

set modelines=0
set number
set ruler
set cursorline
set encoding=utf-8
set history=100
set visualbell
set gcr=a:blinkon0
set autoread
set hidden

set completeopt=menu,menuone,noinsert
set macligatures " ligature support in macvim
set guifont=FiraCode-Retina:h14
set noswapfile
set nobackup
set nowb

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
set matchpairs+=<:>

set incsearch
set ignorecase
set nohlsearch

set ttyfast
set laststatus=2

set showmode
set showcmd

set t_Co=256
set background=dark

let g:solarized_termcolors=256
colorscheme OceanicNext

" nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc()==0 && !exists("s:std_in") | NERDTree | endif
" autocmd bufenter * if (winnr("$")==1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
map <C-n> :NERDTreeToggle<CR>

" airline
let g:airline_theme='solarized'
let g:airline_solarized_bg='dark'

" tagbar
map <C-m> :TagbarToggle<CR>

" ctrlp
let g:ctrlp_map='<C-p>'
let g:ctrlp_working_path_mode='ra'

" syntastic
let python_highlight_all=1
let g:syntastic_python_python_exec = 'python3'
let g:syntastic_python_checkers = ['flake8']

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list=1
let g:syntastic_auto_loc_list=1
let g:syntastic_check_on_open=1
let g:syntastic_check_on_wq=0

" autopairs
let g:AutoPairs={'(':')', '[':']', '{':'}',"'":"'",'"':'"', '`':'`', '<':'>', '<<':''}

" youcompleteme
let g:ycm_min_num_of_chars_for_completion=1
let g:ycm_global_ycm_extra_conf='~/.vim/bundle/YouCompleteMe/third_party/ycmd/.ycm_extra_conf.py'
map <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>

" autoformat
let g:formatterpath=['/usr/bin/autopep8']
map <C-f> :Autoformat<CR>

" custom
map <C-w><C-l> :lclose<CR>

" C-v : open file in vertical split using ctrlp
" C-h : open file in horizontal split using ctlrp
" C-w + arrow : navigate between splits in normal mode
" C-o : return to previous buffer
" C-w + z : close scratch buffer
" C-w + C-l : lclose : close syntastic error list

" C-b : tmux super
"     + d : detach session
"     + % : split vertically
"     + " : split horizontally

