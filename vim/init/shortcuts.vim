" tabs
nnoremap <M-Left> :tabprevious<CR>
nnoremap <M-Right> :tabnext<CR>
nnoremap <C-t> :tabnew<CR>
inoremap <C-t> <C-o>:tabnew<CR>
inoremap <M-Left> <C-o>:tabprevious<CR>
inoremap <M-Right> <C-o>:tabnext<CR>

" windows
" nnoremap <Tab> <C-w>w

" folding
nnoremap <Space> za

" clear the search buffer when hitting return
nnoremap <CR> :nohlsearch<CR>

nnoremap <F3> :Explore<CR>

nnoremap <C-D> :confirm qa<CR>
inoremap <C-D> <ESC>:confirm qa<CR>

" Remap leader key to ,
let mapleader=","

" Disable the arrow keys
" noremap <up> :echom 'k moves up'<CR>
" noremap <down> :echom 'j moves down'<CR>
" noremap <left>  :echom 'h moves left'<CR>
" noremap <right> :echom 'l moves right'<CR>
" inoremap <up> <C-o>:echoerr 'k moves up'<CR>
" inoremap <down> <C-o>:echoerr 'j moves down'<CR>
" inoremap <left>  <C-o>:echoerr 'h moves left'<CR>
" inoremap <right> <C-o>:echoerr 'l moves right'<CR>

" noremap <up> <nop>
" noremap <down> <nop>
" noremap <left> <nop>
" noremap <right> <nop>
inoremap <expr><up> pumvisible() ? "\<up>" : ""
inoremap <expr><down> pumvisible() ? "\<down>" : ""
inoremap <left> <Nop>
inoremap <right> <Nop>

inoremap <expr><CR>  neocomplcache#close_popup()
if has('gui_running')
    inoremap <C-space> <C-n>
else
    inoremap <nul> <C-n>
endif

" / and ? in visual mode search in range
function! RangeSearch(direction)
  call inputsave()
  let g:srchstr = input(a:direction)
  call inputrestore()
  if strlen(g:srchstr) > 0
    let g:srchstr = g:srchstr.
          \ '\%>'.(line("'<")-1).'l'.
          \ '\%<'.(line("'>")+1).'l'
  else
    let g:srchstr = ''
  endif
endfunction
vnoremap <silent> / :<C-U>call RangeSearch('/')<CR>:if strlen(g:srchstr) > 0\|exec '/'.g:srchstr\|endif<CR>
vnoremap <silent> ? :<C-U>call RangeSearch('?')<CR>:if strlen(g:srchstr) > 0\|exec '?'.g:srchstr\|endif<CR>
