" ==============================================================================
" vim plugin configuration - github.com/lukeelmers/dotfiles
" ==============================================================================
" /* vim: set fdm=marker : */


" SETUP --------------------------------------------------------------------{{{

" Autoinstall and run plug.vim
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall
endif

call plug#begin('~/.vim/bundle')

Plug 'connorholyday/vim-snazzy'                                                     " theme
Plug 'mhinz/vim-startify'                                                           " vim startup screen
Plug 'ctrlpvim/ctrlp.vim'                                                           " fuzzy file searching
Plug 'rking/ag.vim'                                                                 " faster grepping
Plug 'bling/vim-airline'                                                            " pretty status bar
Plug 'vim-airline/vim-airline-themes'                                               " status bar theme
Plug 'scrooloose/nerdtree'                                                          " sidebar navigation
Plug 'Xuyuanp/nerdtree-git-plugin'                                                  " git diff support for nerdtree
Plug 'tpope/vim-fugitive'                                                           " git goodness
Plug 'airblade/vim-gitgutter'                                                       " show git diffs in gutter
Plug 'vim-scripts/gitignore'                                                        " set wildignore to match .gitignore
Plug 'rstacruz/sparkup'                                                             " emmet-style html expanding
Plug 'terryma/vim-multiple-cursors'                                                 " multiple cursors like Sublime (ctrl+n)
Plug 'terryma/vim-expand-region'                                                    " expand selection in visual mode with +/-
Plug 'tpope/vim-commentary'                                                         " comment out lines with gc, gcc, gcap
Plug 'tpope/vim-surround'                                                           " use s to select surrounding tags or brackets
Plug 'tpope/vim-sleuth'                                                             " autoconfigure indentation settings
Plug 'godlygeek/tabular'                                                            " run :Tabularize /{,|=|'|etc} to autoalign text
Plug 'Raimondi/delimitMate'                                                         " automatically add closing brackets
Plug 'joeytwiddle/sexy_scroller.vim'                                                " smooth scrolling
Plug 'tpope/vim-rails'                                                              " rails support
Plug 'tpope/vim-endwise'                                                            " automatically add 'end' in ruby
Plug 'cakebaker/scss-syntax.vim'                                                    " scss support (requires JulesWang/css.vim)
Plug 'gorodinskiy/vim-coloresque'                                                   " highlight color names and hex codes
Plug 'pangloss/vim-javascript'                                                      " js syntax highlighting
Plug 'mxw/vim-jsx'                                                                  " react jsx highlighting
Plug 'kchmck/vim-coffee-script'                                                     " coffeescript syntax highlighting
Plug 'othree/html5.vim'                                                             " html5 syntax
Plug 'suan/vim-instant-markdown', { 'do': 'npm -g install instant-markdown-d' }     " instant previews of markdown files
Plug 'Valloric/YouCompleteMe', { 'do': './install.sh --clang-completer', 'on': [] } " code completion
" Install devicons last and download to local Fonts directory
Plug 'ryanoasis/vim-devicons', { 'do': 'cd ~/Library/Fonts && curl -fLo Sauce\ Code\ Pro\ Plus\ Nerd\ File\ Types.ttf https://github.com/ryanoasis/nerd-fonts/blob/0.6.1/patched-fonts/SourceCodePro/Sauce%20Code%20Pro%20Plus%20Nerd%20File%20Types.ttf' }

call plug#end()

" }}}


" CONFIGURATION ------------------------------------------------------------{{{

" Theme & Font {{{
syntax enable
colorscheme snazzy
set background=dark
set colorcolumn=80,120
if has('nvim')
  let $NVIM_TUI_ENABLE_TRUE_COLOR=1
else
  set t_Co=256
endif
" Set devicons guifont (must set in preferences if using non-gui terminal)
if has('gui_running')
  set guifont=Sauce\ Code\ Pro\ Plus\ Nerd\ File\ Types\ 16
endif
" }}}

" Syntax Highlighting {{{
let g:jsx_ext_required = 0 " Allow JSX in normal JS files
"  }}}

" Smooth Scrolling {{{
let g:SexyScroller_ScrollTime = 200
let g:SexyScroller_CursorTime = 0
let g:SexyScroller_MaxTime = 1000
let g:SexyScroller_EasingStyle = 3
" }}}

" Multiple Cursors {{{
let g:multi_cursor_use_default_mapping=0
let g:multi_cursor_next_key='<C-m>'     " change to avoid conflicts with NerdTREE
let g:multi_cursor_prev_key='<C-p>'     " default
let g:multi_cursor_skip_key='<C-x>'     " default
let g:multi_cursor_quit_key='<Esc>'     " default
" }}}

" Instant Markdown {{{
let g:instant_markdown_slow = 1
" let g:instant_markdown_autostart = 0
" }}}

" NERDTree {{{
map <C-n> :NERDTreeToggle<CR>
let NERDTreeDirArrows = 1
let NERDTreeShowHidden = 1
let NERDTreeAutoDeleteBuffer = 1
let NERDTreeShowBookmarks = 1
let NERDTreeMinimalUI = 1
let NERDTreeWinSize = 40
let NERDTreeChDirMode = 2
" }}}

" YouCompleteMe {{{
" load first time insert mode is entered
if v:version >= 740
  augroup load_ycm
    autocmd!
    autocmd InsertEnter * call plug#load('YouCompleteMe') | call youcompleteme#Enable() | autocmd! load_ycm
  augroup END
endif
" }}}

" Airline {{{
" Make sure powerline fonts are used
let g:airline_powerline_fonts=1
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_theme="minimalist"
set laststatus=2                                     " Show airline even if there isn't a split
let g:airline#extensions#tabline#enabled = 1         " Enable the tabline
let g:airline#extensions#tabline#fnamemod = ':t'     " Show just the filename of buffers in the tab line
let g:airline#extensions#tabline#buffer_nr_show = 1  " Show buffer numbers
let g:airline#extensions#branch#enabled = 1          " Enable Fugitive integration
let g:airline_detect_modified=1
let g:airline_detect_paste=1
" }}}

" CtrlP {{{
" Type <Space>o to open a new file
nnoremap <Leader>o :CtrlP<CR>
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_match_window = 'bottom,order:ttb'
let g:ctrlp_switch_buffer = 0

"Use ag/silver searcher for grepping and ctrlP
if executable('ag')
    " Use ag over grep
    set grepprg=ag\ --nogroup\ --nocolor

    " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
    let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

    " ag is fast enough that CtrlP doesn't need to cache
    let g:ctrlp_use_caching = 0
else
  let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files . -co --exclude-standard', 'find %s -type f']
  let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<space>', '<cr>', '<2-LeftMouse>'],
    \ }
endif
" }}}

" Startify {{{
let g:startify_change_to_dir = 0
let g:startify_bookmarks = [ 
        \ '~/.vimrc',
        \ '~/.bash_profile',
        \ '~/.vim/plugins.vim',
    \ ]
let g:startify_skiplist = [
       \ 'COMMIT_EDITMSG',
       \ fnamemodify($VIMRUNTIME, ':p') .'/doc',
       \ 'bundle/.*/doc',
       \ '\.DS_Store'
    \ ]
let g:startify_custom_header = [
    \ '               __   ',
    \ '              / _)  ',
    \ '       .-^^^-/ /    ',
    \ '    __/       /     ',
    \ '   <__.|_|-|_|      ',
    \ '                    ',
    \ ]
" }}}

" }}}

