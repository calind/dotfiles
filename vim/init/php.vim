" au BufNewFile,BufRead wp-*.php,*plugins/*.php,*themes/*.php,wp-*/*.php set noexpandtab softtabstop=4 tabstop=4 shiftwidth=4 textwidth=79 listchars+=tab:\ \ 

au FileType php setl noexpandtab softtabstop=2 tabstop=4 shiftwidth=4 textwidth=79 nolist

" highlights interpolated variables in sql strings and does sql-syntax highlighting. yay
" au FileType php let php_sql_query=1
" does exactly that. highlights html inside of php strings
" au FileType php let php_htmlInStrings=1
" discourages use oh short tags. c'mon its deprecated remember
au FileType php let php_noShortTags=1
" automagically folds functions & methods. this is getting IDE-like isn't it?
au FileType php let php_folding=1

