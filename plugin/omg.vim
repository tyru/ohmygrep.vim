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

if !exists('g:omg_wildignore')
    let g:omg_wildignore = [
    \   '.bzr',
    \   '.git',
    \   '.hg',
    \   '.svn',
    \   'CVS',
    \   'RCS',
    \   'SCCS',
    \   '_darcs',
    \   '_sgbak',
    \
    \   'autom4te.cache',
    \
    \   'tags',
    \]
endif

if !exists('g:omg_use_vimgrep')
    let g:omg_use_vimgrep = 1
endif


try
    call operator#user#define('grep', 'omg#op_grep')
catch
    " Shut up
endtry


nnoremap <Plug>(omg-grep-cword) :<C-u>call omg#grep(expand('<cword>'), g:omg_default_flags, ['**/*'])<CR>
nnoremap <Plug>(omg-grep-cWORD) :<C-u>call omg#grep(expand('<cWORD>'), g:omg_default_flags, ['**/*'])<CR>


command!
\   -bang -nargs=* -complete=file
\   OMGrep
\   call omg#_cmd_grep(<q-args>, <bang>0)

command!
\   -nargs=+
\   OMReplace
\   call omg#_cmd_replace(<f-args>)


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
