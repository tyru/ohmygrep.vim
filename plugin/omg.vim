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
    let g:omg_default_flags = 'j' . (&smartcase ? 's' : '')
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


let s:V = vital#of('ohmygrep')
let s:Buffer = s:V.import('Vim.Buffer')
function! s:get_selected_text()
    return s:Buffer.get_selected_text()
endfunction

nnoremap <Plug>(omg-grep-cword) :<C-u>call omg#grep(expand('<cword>'), g:omg_default_flags, ['**/*'])<CR>
nnoremap <Plug>(omg-grep-cWORD) :<C-u>call omg#grep(expand('<cWORD>'), g:omg_default_flags, ['**/*'])<CR>

nnoremap <Plug>(omg-grep-cword-word) :<C-u>call omg#grep(expand('<cword>'), g:omg_default_flags . 'w', ['**/*'])<CR>
nnoremap <Plug>(omg-grep-cWORD-word) :<C-u>call omg#grep(expand('<cWORD>'), g:omg_default_flags . 'w', ['**/*'])<CR>

vnoremap <Plug>(omg-grep-selected) :<C-u>call omg#grep(<SID>get_selected_text(), g:omg_default_flags, ['**/*'])<CR>


command!
\   -bang -nargs=*
\   OMGrep
\   call omg#_cmd_grep(<q-args>, <bang>0)

command!
\   -nargs=+
\   OMReplace
\   call omg#_cmd_replace(<f-args>)

command!
\   -nargs=* -complete=dir
\   OMFind
\   call omg#_cmd_find(<f-args>)


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
