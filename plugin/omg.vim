" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_omg') && g:loaded_omg
    finish
endif
let g:loaded_omg = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}




if !exists('g:omg_default_files')
    let g:omg_default_files = ['**/*']
endif

if !exists('g:omg_default_flags')
    let g:omg_default_flags = 'j'
endif


try
    call operator#user#define('grep', 'omg#op_grep')
catch
    " Shut up
endtry


nnoremap <Plug>(omg-grep-cword) :<C-u>call omg#do_grep(expand('<cword>'), ['**/*'])<CR>
nnoremap <Plug>(omg-grep-cWORD) :<C-u>call omg#do_grep(expand('<cWORD>'), ['**/*'])<CR>


command!
\   -bang -nargs=*
\   OMGrep
\   call omg#_cmd_grep(<q-args>, <bang>0)



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
