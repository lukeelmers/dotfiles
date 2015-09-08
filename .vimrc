" ==============================================================================
" vimrc - github.com/lukeelmers/dotfiles
" ==============================================================================
" /* vim: set fdm=marker : */

set nocompatible
set encoding=utf8


" GENERAL ------------------------------------------------------------------{{{

set cursorline                  " Highlight underneath cursor
set number                      " Line numbers
set backspace=indent,eol,start  " Allow backspace in insert mode
set visualbell                  " No sounds
set autoread                    " Reload files changed outside vim
set showmatch                   " Show matching parenthesis
set undolevels=1000             " Store lots of undo
set history=1000                " Store lots of history
set noswapfile                  " Disable .swp file creation
set nobackup
set nowb

" Use tab key to match bracket or tag pairs
nnoremap <tab> %
vnoremap <tab> %
if v:version >= 600
  runtime macros/matchit.vim
endif

" Map semicolon to colon in all modes, and hit semicolon twice if holding shift
map ; :
noremap ;; ;

" Map jj to ESC for quicker escaping
inoremap jj <ESC>

" Let buffers exist in the background without being in a window.
set hidden

" Change leader to a space
let mapleader="\<Space>"

" }}}


" PLUGINS ------------------------------------------------------------------{{{

" This loads all the plugins specified in ~/.vim/plugins.vim
if filereadable(expand("~/.vim/plugins.vim"))
  source ~/.vim/plugins.vim
endif

filetype plugin on
filetype indent on

" }}}


" TEXT & TABS --------------------------------------------------------------{{{

set wrap                      " Wrap lines
set linebreak                 " Wrap lines at convenient points
set nolist                    " List disables linebreak
set textwidth=79
if v:version > 740
    set breakindent
endif

" Display tabs and trailing spaces visually
set list listchars=tab:\ \ ,trail:·

" }}}


" SCROLLING & FOLDING ------------------------------------------------------{{{

set scrolloff=8         "Start scrolling when we're 8 lines away from margins
set sidescrolloff=15
set sidescroll=1

set foldmethod=indent
set foldnestmax=10
set nofoldenable        " no folding by default
set foldlevelstart=99   " don't fold everything the first time you hit za

" }}}


" SEARCH -------------------------------------------------------------------{{{

set incsearch                     " Find the next match as we type the search
set hlsearch                      " Highlight searches by default
set ignorecase                    " Ignore case when searching...
set smartcase                     " ...unless we type a capital
" Leader + Space to clear search highlight
nnoremap <leader><space> :noh<cr>

" }}}


" OTHER --------------------------------------------------------------------{{{

" Copy to and from system clipboard
set clipboard=unnamed,unnamedplus

" Recognize .md file as markdown
autocmd BufNewFile,BufReadPost *.md set filetype=markdown

" Open current document in default application (use to open html files in browser)
map <Leader>b :!open %<CR><CR>

" Quickly edit/reload the vimrc file
nmap <silent> <leader>ev :e $MYVIMRC<CR>
nmap <silent> <leader>sv :so $MYVIMRC<CR>

" Additional settings for neovim
if has('nvim')
  " Enter terminal emulator with <leader>t
  nnoremap <leader>t :terminal<cr>
  " Exit terminal emulator with <Esc> or <C-w><C-w>
  tnoremap <Esc> <C-\><C-n>
  tnoremap <C-w><C-w> <C-\><C-n><C-w><C-w>
endif

" Debug syntax highlighting: place cursor on any character and type :call SynStack()
fun! SynStack()
    if !exists("*synstack")
        return
    endif
    echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfun

" }}}

