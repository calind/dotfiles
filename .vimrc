set nocompatible                " disable vi compatibility mode
set encoding=utf-8              " use utf8 by default
execute pathogen#infect()

syntax on                       " Highlight known syntaxes
filetype plugin indent on       " Enable filetype detection, and per filetype plugins and indentation

set showcmd                     " display incomplete commands

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=4 shiftwidth=4      " a tab is two spaces (or set this to 4)
set expandtab                   " expand tab by default
set backspace=indent,eol,start  " backspace through everything in insert mode
set textwidth=80                " 80 columns by default

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

"" Code editing
set autoindent
set nonumber                    " don't show line numbers by default
set ruler                       " show the cursor position all the time
set cursorline                  " highlight the line of the cursor
set modeline                    " respect modeline
set colorcolumn=+1              " show vertical line after textwidth

"" Ignore some files
set wildignore+=*.pyc

"" Sanitize workflow
set shell=bash                  " avoids munging PATH under zsh
let g:is_bash=1                 " default shell syntax
set history=200                 " remember more Ex commands
set scrolloff=3                 " have some context around the current line always on screen
set synmaxcol=1000              " don't try to highlight long lines
set hidden                      " allow backgrounding unsaved buffers
set autoread                    " auto-reload buffers when file changed on disk
set nojoinspaces                " Use only 1 space after "." when joining lines, not 2
let mapleader=","               " remap leader to ,
" set clipboard=unnamed           " use system clipboard
" set mouse=a                     " enable mouse selection
" Remember last location in file, but not for commit messages.
" see :help last-position-jump
au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
            \| exe "normal! g`\"" | endif

"" Backups, undos and other safeties
set backup
set backupdir=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set backupskip=/tmp/*,/private/tmp/*
set directory=~/.vim-tmp,~/.tmp,~/tmp,/var/tmp,/tmp
set writebackup

"" Indicator chars
set list
set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮
set showbreak=↪\

" Avoid showing trailing whitespace when in insert mode
au InsertEnter * set listchars-=trail:•
au InsertLeave * set listchars+=trail:•

"" Colors and UI
set splitright
set title " automatically set window title
set termguicolors
colorscheme solarized8_dark
set wildmenu " visual autocomplete for command menu
set lazyredraw          " redraw only when we need to.

" Configure status line "{{{
" Set viertualenv statusline format
let g:virtualenv_stl_format = '[%n]'

if has("statusline") && !&cp
    set laststatus=2              " always show the status bar
    set statusline=%f\ %m\ %r     " filename, modified, readonly
    set statusline+=%{virtualenv#statusline()}
    set statusline+=\ %y          " filetype
    set statusline+=\ %l/%L[%p%%] " current line/total lines
    set statusline+=\ %v[0x%B]    " current column [hex char]
    set statusline+=\ [%{&fileencoding?&fileencoding:&encoding}]
endif
"}}}

" Configure filetypes "{{{
au BufRead,BufNewFile $HOME/bashrc.d/* setf sh
au BufRead,BufNewFile Dockerfile* setf Dockerfile

au FileType python set textwidth=100 colorcolumn=80
au FileType make set noexpandtab
au Filetype json set tabstop=2 shiftwidth=2
au Filetype markdown setl wrap wrapmargin=2 textwidth=80
au Filetype yaml setl shiftwidth=2 tabstop=2
au FileType terraform setlocal commentstring=#%s textwidth=100 colorcolumn=80 tabstop=2 shiftwidth=2
"}}}

" Key mappings "{{{
" remove trailing whitespace with <leader>,
command! KillWhitespace :normal :%s/ *$//g<cr><c-o><cr>
nnoremap <Leader>w :KillWhitespace<CR>
" clear the search buffer when hitting return
nnoremap <CR> :nohlsearch<CR>
" close neocomplete popup with return key
inoremap <expr><CR>  neocomplete#close_popup()
" comment/uncomment using double backslash
if maparg('\\','n') ==# '' && maparg('\','n') ==# '' && get(g:, 'commentary_map_backslash', 1)
  xmap \\  <Plug>Commentary<CR>
  nmap \\  <CR><Plug>Commentary
  nmap \\\ <Plug>CommentaryLine<CR>
  nmap \\u <Plug>CommentaryUndo<CR>
endif
" }}}

" Configure vim-rooter "{{{
function s:project_vimrc()
    if filereadable(glob("./.vimrc")) && getcwd() != $HOME
        silent source ./.vimrc
    endif
endfunction

let g:rooter_use_lcd = 1
let g:rooter_silent_chdir = 1
let g:rooter_patterns = ['.project', '.git', '.git/', '_darcs/', '.hg/', '.bzr/', '.svn/']
autocmd BufEnter * Rooter
autocmd BufEnter * :call s:project_vimrc()
" }}}

" Configure jedi-vim "{{{
au FileType python setl omnifunc=jedi#completions
au FileType python.django setl omnifunc=jedi#completions
let g:jedi#show_call_signatures = 0 " disable function signatures since it slow everything down
let g:jedi#use_tabs_not_buffers = 0 " we use buffers. tabs are are for whimps
" make jedi-vim play nice with neocomplete
let g:jedi#completions_enabled = 0
let g:jedi#auto_vim_configuration = 0
let g:jedi#smart_auto_mappings = 0
"}}}

" Configure php "{{{

au BufRead,BufNewFile *.phpt setf php
au FileType php setl noet ci pi sts=0 sw=4 ts=4
au FileType php setl nolist
" }}}"

" Configure go "{{{
au FileType go setl nolist
au FileType go nnoremap <Leader>d :GoDef<CR>

let g:neomake_go_go_exe = 'env'
let g:neomake_go_go_args = ['GOGC=off', 'go', 'test', '-i', '-installsuffix', 'test_vim', '-c', '-o', '/dev/null']
" }}}"

" Configure Dockerfile"{{{

au FileType dockerfile setl textwidth=0 colorcolumn=80 " disable automatic line wrapping but show the gutter at column 80
" }}}"

" Configure neocomplete "{{{
let g:neocomplete#enable_at_startup = 1
let g:neocomplete#enable_smart_case = 1
let g:neocomplete#sources#syntax#min_keyword_length = 3

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
            \ 'default' : '',
            \ 'vimshell' : $HOME.'/.vimshell_hist',
            \ }

let g:neocomplete#keyword_patterns = {
            \ 'default': '\h\w*'
            \ }

let g:neocomplete#force_omni_input_patterns = {
            \ 'python': '\%([^. \t]\.\|^\s*@\|^\s*from\s.\+import \|^\s*from \|^\s*import \)\w*'
            \ }

autocmd CmdwinEnter * let b:neocomplete_sources = ['vim']
" }}}

" Configure neomake "{{{
" Prettify signs
highlight SignColumn cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=0 guibg=#073642
highlight NeomakeErrorSign ctermbg=0 ctermfg=red
highlight NeomakeWarningSign ctermbg=0 ctermfg=2
highlight NeomakeMessageSign ctermbg=0 ctermfg=4
highlight NeomakeInfoSign ctermbg=0 ctermfg=4

" show signs column by default
autocmd BufEnter * sign define dummy
autocmd BufEnter * execute 'sign place 9999 line=1 name=dummy buffer=' . bufnr('')

let g:neomake_message_sign = {
            \   'text': '❯',
            \   'texthl': 'NeomakeMessageSign',
            \ }

call neomake#configure#automake('nrw', 1000)
"}}}

" Configure ansible-vim "{{{
let g:ansible_attribute_highlight = "ad"
let g:ansible_name_highlight = "b"
let g:ansible_extra_keywords_highlight = 0
" }}}
" vim:foldmethod=marker:foldlevel=0
