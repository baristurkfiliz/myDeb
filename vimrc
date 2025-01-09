" Genel Ayarlar
set encoding=utf-8
set hidden
set undofile
"set noexpandtab " Tab tuşunun davranışını değiştirmek istemiyorsanız bu satırı yorum satırı yapın
set shiftwidth=1 " Tab genişliği 1 karakter
set tabstop=1    " Tab tuşu 1 karakterlik boşluk eklesin
set autoindent
set cursorline
set scrolloff=8
set wildmenu
set hlsearch
set incsearch
set ignorecase
set smartcase
set wrap
set splitbelow
set splitright
set termguicolors
syntax enable

" Plugin Yönetimi
call plug#begin('~/.vim/plugged')
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'dense-analysis/ale'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdcommenter'
Plug 'sheerun/vim-polyglot' " Dil desteği, bazı autocmd komutlarını gereksiz kılabilir
Plug 'tpope/vim-fugitive'
call plug#end()

" Kısayollar
nnoremap <C-n> :NERDTreeToggle<CR>

" ALE Ayarları
let g:ale_linters = {
\   'python': ['flake8'],
\   'c,cpp': ['gcc', 'g++'],
\   'bash': ['shellcheck']
\ }
let g:ale_fix_on_save = 1
let g:ale_fixers = {
\   '*': ['remove_trailing_lines', 'trim_whitespace'],
\   'python': ['autopep8'],
\   'c,cpp': ['clang-format'],
\   'html': ['prettier'],
\   'bash': ['shfmt']
\ }

" Vim-Airline Ayarları
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
