" https://github.com/vim/vim/issues/3117 {{{
if has('python3') && !has('patch-8.1.201')
  silent! python3 1
endif
"}}}

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
set synmaxcol=500               " don't try to highlight long lines
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

"" Spell checking. I'm really bad at spelling
set spellfile=~/.vim/spell/techspeak.utf-8.add
set spell

" Configure status line "{{{
" Set viertualenv statusline format
" let g:virtualenv_stl_format = '[%n]'

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

" Configure lightline "{{{

" Disable mode showing since it's shown in lightline
set noshowmode

let g:lightline = {}
let g:lightline.active = {}
let g:lightline.component_function = {}

let g:lightline.colorscheme = 'solarized'
let g:lightline.active.left = [['mode', 'paste'], ['readonly', 'filename', 'modified'], ['virtualenv']]
let g:lightline.active.right = [['lineinfo'], ['percent'], ['fileformat', 'fileencoding', 'filetype' ], ['linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok']]

let g:lightline.component_function.virtualenv = 'virtualenv.statusline'

let g:lightline.component_expand = {
      \  'linter_checking': 'lightline#ale#checking',
      \  'linter_warnings': 'lightline#ale#warnings',
      \  'linter_errors': 'lightline#ale#errors',
      \  'linter_ok': 'lightline#ale#ok',
      \ }

let g:lightline.component_type = {
      \     'linter_checking': 'left',
      \     'linter_warnings': 'warning',
      \     'linter_errors': 'error',
      \     'linter_ok': 'left',
      \ }

let g:lightline#ale#indicator_checking = '●●●'
let g:lightline#ale#indicator_warnings = '⚠ '
let g:lightline#ale#indicator_errors = '✖ '
let g:lightline#ale#indicator_ok = ' ✔ '

"}}}

" Configure ale "{{{
let g:ale_linters = {}
let g:ale_fixers = {}
let g:ale_sign_column_always = 1
let g:ale_fix_on_save = 1
let g:ale_sign_error = '✖'
let g:ale_sign_warning = '❯'
let g:ale_lint_on_text_changed = 'never'

highlight SignColumn cterm=NONE gui=NONE ctermfg=NONE guifg=NONE ctermbg=0 guibg=#073642
highlight ALEErrorSign ctermbg=0 ctermfg=red
highlight ALEWarningSign ctermbg=0 ctermfg=2
"}}}

" Configure filetypes "{{{
au BufRead,BufNewFile $HOME/bashrc.d/* setf sh
au BufRead,BufNewFile Dockerfile* setf Dockerfile
au BufRead,BufNewFile fluent.conf setf fluentd

au FileType fluentd setl commentstring=#%s
au FileType python set textwidth=100 colorcolumn=80
au FileType make set noexpandtab
au Filetype json set tabstop=2 shiftwidth=2
au Filetype markdown setl wrap wrapmargin=2 textwidth=80
au Filetype yaml setl shiftwidth=2 tabstop=2
au FileType terraform setlocal commentstring=#%s textwidth=100 colorcolumn=80 tabstop=2 shiftwidth=2
"}}}

" Key mappings "{{{

" Write this in your vimrc file
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

nmap <Leader>l <Plug>(qf_qf_toggle)
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
au FileType php setl textwidth=120

" WordPress indents
au BufRead,BufNewFile wp-*.php,class-*.php,wp-includes/*.php,wp-admin/*.php,object-cache.php,advanced-cache.php setf php.wp
au FileType php.wp setl noet ci pi sts=0 sw=4 ts=4
au FileType php.wp setl nolist

" }}}"

" Configure go "{{{
au FileType go setl nolist
au FileType go nnoremap <Leader>d :GoDef<CR>
au FileType go nnoremap <Leader>r :GoRename<CR>
let g:go_fmt_autosave = 0 " We use ale for gofmt and goimports
let g:go_fmt_fail_silently = 1
let g:go_fmt_command = "gofmt"
let g:go_def_mapping_enabled = 1

let g:ale_go_gofmt_options = '-s'
let g:ale_go_goimports_options = '-local github.com/presslabs'
let g:ale_fixers.go = ['gofmt', 'goimports', 'remove_trailing_lines', 'trim_whitespace']

let g:ale_go_golangci_lint_options = '--fast'
let g:ale_linters.go = ['golangci-lint', 'govet', 'gobuild']
" }}}"

" Configure ansible-vim "{{{
let g:ansible_attribute_highlight = "ad"
let g:ansible_name_highlight = "b"
let g:ansible_extra_keywords_highlight = 0
" }}}
" vim:foldmethod=marker:foldlevel=0
