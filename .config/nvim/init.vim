"""" file:	.vimrc
"""" desc:	vim configuration file.
""

call plug#begin()

Plug 'https://github.com/bling/vim-airline'
#Plug 'https://github.com/Shougo/deoplete.nvim.git', { 'do': ':UpdateRemotePlugins' }
#Plug 'zchee/deoplete-jedi'
Plug 'arcticicestudio/nord-vim'
"Plug 'carlitux/deoplete-ternjs', { 'do': 'npm install -g tern' }
"Plug 'isRuslan/vim-es6'

call plug#end()

"" Use tab to traverse autocomplete
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
"filetype plugin indent on

if has('nvim')

    "" Enable deoplete autocomplete
    #let g:deoplete#enable_at_startup = 1

    "" Disable the preview window
    #set completeopt-=preview
endif

autocmd BufReadPost * if @% !~# '\.git[\/\\]COMMIT_EDITMSG$' && line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g`\"" | endif

set noincsearch 

"" Vim airline settings
"let g:airline_powerline_fonts = 1
set laststatus=2

"" Prevent automatic indentation removal from python/bash comments
"" ^H is entered with Ctrl-V Ctrl-H
inoremap # X#

" Remap the escape key to Alt h
if has('nvim')
    noremap! <A-h> <Esc>
    map <A-h> <Esc>
else
    imap <A-h> <Esc>
endif

"" Syntax highlighting
syntax on

"" 80 char wide lines
set textwidth=90
"" 256 colors, remember to enable in PuTTY
set t_Co=256
"" Vim command history limited to 200 commands
set history=200
"" Use line numbers
set number
"" Use relative line numbers (unsupported by older versions on the ECS servers)
if exists('+relativenumber')
	set relativenumber
endif
"" Default to case-insensitive searches
set ignorecase
"" Case-sensitive searches depending on the given pattern
set smartcase
"" Don't highlight shit when searching
set nohlsearch
"" Color scheming
set background=dark
"colorscheme b16-term
colorscheme nord
"" Don't convert tabs to spaces
set expandtab
set smarttab
"" Number of columns used for indents
set shiftwidth=4
"" Number of columns used for tabs
set tabstop=4
"" Auto indent based on indentation from the previous line
set ai
"" Inserts a level of indentation in certain cases
set si
"" Highlight matching braces
set showmatch
"" Hit F2 for copy pasta mode
set pastetoggle=<F2>
"" Fix backspace
set backspace=2
"" Column + row numbers in the status line
set ruler
set clipboard=unnamedplus

"" Treat some files differently depending on their extensions.
"" Text files, most of these options are useful for prose editing
autocmd BufRead,BufNewFile *.txt setlocal textwidth=90 wrap linebreak nolist wrapmargin=0 formatoptions+=nt expandtab
"" Files with no extensions are treated as text files
autocmd BufRead,BufNewFile * if &ft == '' | set ft=txt | endif

