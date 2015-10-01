" Unite
let g:unite_source_history_yank_enable = 1
call unite#filters#matcher_default#use(['matcher_fuzzy','matcher_glob'])
call unite#filters#sorter_default#use(['sorter_rank'])
nnoremap <leader>f :<C-u>UniteWithCurrentDir -no-split -buffer-name=files -start-insert file/new directory/new file_rec/async:!<cr>
nnoremap <leader>y :<C-u>Unite -no-split -buffer-name=yank    history/yank<cr>
nnoremap <leader>e :<C-u>Unite -no-split -buffer-name=buffer  buffer<cr>
autocmd FileType unite nnoremap <buffer> q :<C-u>UniteClose<cr>
autocmd FileType unite noremap <silent><buffer><expr> <C-s> unite#do_action('split')
autocmd FileType unite noremap <silent><buffer><expr> <C-v> unite#do_action('vsplit')
