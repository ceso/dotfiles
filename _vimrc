"""""""" General Config

" Choose no comatibility with legacy vi
set nocompatible
set encoding=utf-8 
set shell=zsh

"""""""" Plugins

" set the runtime path to include vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim 
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'gmarik/Vundle.vim' 
Plugin 'tell-k/vim-autopep8'
Plugin 'altercation/vim-colors-solarized'
Plugin 'rodjek/vim-puppet'
Plugin 'pearofducks/ansible-vim'
Plugin 'ekalinin/dockerfile.vim'
Plugin 'leshill/vim-json'
Plugin 'mitchellh/vagrant'
Plugin 'scrooloose/nerdtree'
Plugin 'xuyuanp/nerdtree-git-plugin'

" All of your plugins must be addewd before the following line
call vundle#end() " required
filetype plugin indent on " required

"""""""" Search

" Search as characters are entered
set incsearch 
" Highlight matches
set hlsearch
" Ignore case when searching...
set ignorecase
" ...unless we type a capital
set smartcase

"""""""" Identation and comments

" Number of visual spaces per TAB
set tabstop=2
" Number of spaces in tab when editing
set softtabstop=2
" Turn <TAB>s into spaces
set expandtab
" Disable auto indentation
filetype indent off
" Disable auto comments
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

"""""""" Colors

set term=xterm-256color
set t_Co=256
" Turn on highlight text
syntax enable
set background=dark
colorscheme solarized
highlight LineNr ctermfg=darkgray
" Highlight current line
set cursorline
" Highlight current column
set cursorcolumn

"""""""" UI Config

" Shown column to left with number line
set number
" Visual autocomplete for command menu
set wildmenu
" Show the line/columnn number where the cursor is
set ruler
" Enable the use of the mouse 
" set mouse=a

"""""""" NERD tree

" Start NERD tree automatically if no name file was given
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
" Set a ctrl + n as a keybinding for open/close NERD tree
map <C-n> :NERDTreeToggle<CR>

""""""""" Autocmds

" Auto reload vimrc when editing it
autocmd! BufWritePost .vimrc source ~/.vimrc
