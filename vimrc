" ----------
" Vim Config
" ----------
"
"
" How this works:
"
" This file is minimal.  Most of the vim settings and initialization is in
" several files in .vim/init.  This makes it easier to find things and to
" merge between branches and repos.
"
" Please do not add configuration to this file, unless it *really* needs to
" come first or last, like Pathogen and sourcing the machine-local config.
" Instead, add it to one of the files in .vim/init, or create a new one.


" Pathogen (This must happen first.)
" --------

set nocompatible
set encoding=utf-8

runtime bundle/vim-pathogen/autoload/pathogen.vim
let g:vitality_fix_focus = 0 " this has to be set before loading the vitality plugin. https://github.com/sjl/vitality.vim/issues/24
execute pathogen#infect("$HOME/.vim/bundle/{}")
syntax on                       " Highlight known syntaxes
filetype plugin indent on


" Source initialization files
" ---------------------------

runtime! init/**.vim

