" Enable neocompletion at startup
let g:neocomplcache_enable_at_startup = 1

" Enable neocompletion smart case
let g:neocomplcache_enable_smart_case = 1

" Autocomplete keywords faster
let g:neocomplcache_min_syntax_length = 3

" Automatically select first completion option
" let g:neocomplcache_enable_auto_select = 1

" neocomplcache only completefunc
let g:neocomplcache_force_overwrite_completefunc = 1

if !exists('g:neocomplcache_omni_functions')
    let g:neocomplcache_omni_functions = {}
endif
if !exists('g:neocomplcache_force_omni_patterns')
    let g:neocomplcache_force_omni_patterns = {}
endif
if !exists('g:neocomplcache_omni_patterns')
    let g:neocomplcache_omni_patterns = {}
endif
if !exists('g:neocomplcache_keyword_patterns')
    let g:neocomplcache_keyword_patterns = {}
endif

let g:neocomplcache_keyword_patterns._ = '\h\w*'
let g:neocomplcache_omni_functions.python = 'jedi#complete'
let g:neocomplcache_force_omni_patterns.python = '[^. \t]\.\w*'
let g:neocomplcache_omni_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_omni_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" Make jedi-vim play nicely with nocomplcache
let g:jedi#popup_on_dot = 0

autocmd CmdwinEnter * let b:neocomplcache_sources_list = ['vim_complete']
