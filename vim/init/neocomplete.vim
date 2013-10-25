" Enable neocompletion at startup
let g:neocomplete#enable_at_startup = 1

" Enable neocompletion smart case
let g:neocomplete#enable_smart_case = 1

" Autocomplete keywords faster
let g:neocomplete#min_syntax_length = 3

" Automatically select first completion option
" let g:neocomplete_enable_auto_select = 1

" neocomplete only completefunc
let g:neocomplete#force_overwrite_completefunc = 1

if !exists('g:neocomplete#sources#omni#input_patterns')
      let g:neocomplete#sources#omni#input_patterns = {}
endif

if !exists('g:neocomplete#force_omni_input_patterns')
    let g:neocomplete#force_omni_input_patterns = {}
endif
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif

let g:neocomplete#keyword_patterns._ = '\h\w*'
let g:neocomplete#force_omni_input_patterns.python = '[^. \t]\.\w*'
let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" Make jedi-vim play nicely with nocomplcache
let g:jedi#popup_on_dot = 0
let g:jedi#auto_vim_configuration = 0

autocmd CmdwinEnter * let b:neocomplete_sources = ['vim']

" For snippet_complete marker.
"if has('conceal')
"    set conceallevel=2 concealcursor=i
"endif

let g:neosnippet#enable_snipmate_compatibility = 1

let g:neosnippet#snippets_directory = $DOTFILES_DIR . "/vim/bundle/vim-snippets/snippets"

