set showcmd                     " display incomplete commands

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=4 shiftwidth=4      " a tab is two spaces (or set this to 4)
set expandtab                   " expand tab by default
set backspace=indent,eol,start  " backspace through everything in insert mode

"" Searching
set hlsearch                    " highlight matches
set incsearch                   " incremental searching
set ignorecase                  " searches are case insensitive...
set smartcase                   " ... unless they contain at least one capital letter

"" Code editing
set nonumber
set ruler                       " show the cursor position all the time
set cursorline                  " highlight the line of the cursor
set autoindent
set modeline                    " respect modeline

set exrc
set colorcolumn=80              " show vertical line at column 80

"" Ignore some files

set wildignore+=*.pyc

"" Sanitize workflow

set shell=bash      " avoids munging PATH under zsh
let g:is_bash=1     " default shell syntax
set history=200     " remember more Ex commands
set scrolloff=3     " have some context around the current line always on screen
set synmaxcol=800   " don't try to highlight long lines

" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers
set hidden

" Auto-reload buffers when file changed on disk
set autoread

" Disable swap files; systems don't crash that often these days
set updatecount=0

" Make Vim able to edit crontab files again.
set backupskip=/tmp/*,/private/tmp/*"

set nojoinspaces               " Use only 1 space after "." when joining lines, not 2

" Indicator chars
set list
set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮
set showbreak=↪\

set splitright

" Don't split bellow, since I like to have scratch buffer on top
" set splitbelow

" Set viertualenv statusline format
let g:virtualenv_stl_format = '[%n]'

if has("statusline") && !&cp
    set laststatus=2              " always show the status bar
    set statusline=%f\ %m\ %r     " filename, modified, readonly
    set statusline+=%{virtualenv#statusline()}
    set statusline+=\ %y          " filetype
    set statusline+=\ %l/%L[%p%%] " current line/total lines
    set statusline+=\ %v[0x%B]    " current column [hex char]
endif

autocmd VimEnter * Rooter

" Avoid showing trailing whitespace when in insert mode
au InsertEnter * set listchars-=trail:•
au InsertLeave * set listchars+=trail:•

" In Makefiles, use real tabs, not tabs expanded to spaces
au FileType make set noexpandtab

" Make sure all markdown files have the correct filetype set and setup wrapping
autocmd BufNewFile,BufRead *.markdown,*.md,*.mdown,*.mkd,*.mkdn
      \ if &ft =~# '^\%(conf\|modula2\)$' |
      \   set ft=markdown |
      \ else |
      \   setf markdown |
      \ endif

" Treat JSON files like JavaScript
au BufNewFile,BufRead *.json setf javascript

" Set nginx syntax
au BufRead,BufNewFile /etc/nginx/*,/usr/local/nginx/conf/* if &ft == '' | setfiletype nginx | endif
" Set syntax for shell files in my custom locations
au BufRead,BufNewFile *bashrc.d/* if &ft == '' | setfiletype sh | endif

" Remember last location in file, but not for commit messages.
" see :help last-position-jump
au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
            \| exe "normal! g`\"" | endif

" mark Jekyll YAML frontmatter as comment
au BufNewFile,BufRead *.{md,markdown,html,xml} sy match Comment /\%^---\_.\{-}---$/

" disable displaying function definition because F@#$! up with undo/redo
" let g:jedi#show_function_definition = 0

au FileType css setlocal omnifunc=csscomplete#CompleteCSS
au FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
au FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
au FileType python setlocal omnifunc=jedi#completions
au FileType python.django setlocal omnifunc=jedi#completions
au FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
au Filetype markdown setl wrap | setl wrapmargin=2 | setl textwidth=80
au Filetype yaml setl shiftwidth=2 | setl tabstop=2


" set snippets variables
let g:snips_author = $NAME
let g:snips_email = $EMAIL
let g:snips_compary = $COMAPNY

