" make Python follow PEP8 ( http://www.python.org/dev/peps/pep-0008/ )
au FileType python set softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79 | let &commentstring="# %s"

" Projects usually store django templates in templates/ folder
au BufNewFile,BufRead *templates/*.html setlocal filetype=htmldjango

" au FileType htmldjango set omnifunc=htmldjangocomplete#CompleteDjango

" I mainly use html5
let g:htmldjangocomplete_html_flavour = 'html5'

au FileType htmldjango inoremap {% {%  %}<left><left><left>
au FileType htmldjango inoremap {{ {{  }}<left><left><left>

" :python << EOF
" import os
" import sys
" import vim
" virtualenv = os.environ.get('VIRTUAL_ENV')
" if virtualenv:
"     activate_this = os.path.join(virtualenv, 'bin', 'activate_this.py')
"     if os.path.exists(activate_this):
"         execfile(activate_this, dict(__file__=activate_this))
" sys.path.insert(0,os.getcwd())
" EOF
