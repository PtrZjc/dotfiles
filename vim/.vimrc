" gui

colorscheme atom-dark-256

set guifont=Hack\ Regular\ 12

" Disable compatibility with vi which can cause unexpected issues.
set nocompatible

" Enable type file detection. Vim will be able to try to detect the type of file in use.
filetype on

" Enable plugins and load plugin for the detected file type.
filetype plugin on

" Load an indent file for the detected file type.
filetype indent on

" Turn syntax highlighting on.
syntax on

" Add numbers to each line on the left-hand side.
set number

" Highlight cursor line underneath the cursor horizontally.
set cursorline

" While searching though a file incrementally highlight matching characters as you type.
set incsearch

" Show partial command you type in the last line of the screen.
set showcmd

" Show the mode you are on the last line.
set showmode

" Show matching words during a search.
set showmatch

" Use highlighting when doing a search.
set hlsearch
set ignorecase " ignore case in search

" Set the commands to save in history default number is 20.
set history=1000

" Enable auto completion menu after pressing TAB.
set wildmenu

" Make wildmenu behave like similar to Bash completion.
set wildmode=list:longest

" There are certain files that we would never want to edit with Vim.
" Wildmenu will ignore files with these extensions.
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" display width of tab character
set tabstop=4
" number of spaces inserted of deleted by >> and <<
set shiftwidth=4
" behavior of TAB key
set softtabstop=4
" folds below unfolded by default
set foldlevel=1
" always leave 4 free lines on top and bottom
setlocal scrolloff=4

" BEHAVIOR ---------------------------------------------------------------- {{{

  set noswapfile

" }}}

" PLUGINS ---------------------------------------------------------------- {{{

call plug#begin('~/.vim/plugged')

  Plug 'dense-analysis/ale'

  Plug 'preservim/nerdtree'

  Plug 'junegunn/fzf.vim'
  " Enable fzf
  set rtp+=/usr/local/opt/fzf

  Plug 'tpope/vim-commentary'

  Plug 'tpope/vim-repeat'

  Plug 'tpope/vim-surround'

  Plug 'tpope/vim-sensible'

  Plug 'bfrg/vim-jq'

  Plug '907th/vim-auto-save'
  let g:auto_save=1  "enable AutoSave on Vim startup
  let g:auto_save_silent=1
  
  Plug 'AndrewRadev/sideways.vim'

  Plug 'christoomey/vim-system-copy'

  Plug 'terrastruct/d2-vim'

call plug#end()

" }}}

" MAPPINGS --------------------------------------------------------------- {{{
	inoremap jk <ESC>
	let mapleader = "'"

"	noremap  <Up> ""
"	noremap! <Up> <Esc>
"	noremap  <Down> ""
"	noremap! <Down> <Esc>
"	noremap  <Left> ""
"	noremap! <Left> <Esc>
"	noremap  <Right> ""
"	noremap! <Right> <Esc>

" }}}

" VIMSCRIPT -------------------------------------------------------------- {{{

" Enable the marker method of folding.
augroup filetype_vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" }}}

" STATUS LINE ------------------------------------------------------------ {{{

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Show the status on the second to last line.
set laststatus=2
" }}}
