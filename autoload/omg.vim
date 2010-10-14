" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}



" http://vim-users.jp/2010/03/hack129/
" http://vim-users.jp/2010/03/hack130/
" http://webtech-walker.com/archive/2010/03/17093357.html



function! omg#op_grep(motion_wiseness) "{{{
    " TODO
endfunction "}}}


function! omg#_cmd_grep(args, bang) "{{{
    try
        let args_list = s:grep_parse_args(a:args, g:omg_default_flags)
    catch /^parse error$/
        echohl WarningMsg
        echomsg v:exception
        echohl None
        return
    endtry

    if empty(args_list)
        " :Grep
        let word = '/' . @/ . '/' . g:omg_default_flags
        let files = deepcopy(g:omg_default_files)
    elseif len(args_list) == 1
        " :Grep {pattern}
        let word = args_list[0]
        let files = deepcopy(g:omg_default_files)
    else
        " :Grep {files}[, {more files}] {pattern}
        let files = args_list[: -2]
        let word = args_list[-1]
    endif

    call omg#grep(word, files, a:bang)
endfunction "}}}

function! s:skip_white(str) "{{{
    return substitute(a:str, '^\s\+', '', '')
endfunction "}}}

function! s:parse_pattern(str, pat) "{{{
    let str = a:str
    let head = matchstr(str, a:pat)
    let rest = strpart(str, strlen(head))
    return [head, rest]
endfunction "}}}

function! s:grep_parse_args(args, default_flags) "{{{
    let GREP_WORD_PAT = '^/.\{-}[^\\]/[gj]*' . '\C'
    let ARGUMENT_PAT  = '^.\{-}[^\\]\ze\([ \t]\|$\)'
    let args = a:args
    let list = []
    while args != ''
        let args = s:skip_white(args)

        if args =~# GREP_WORD_PAT
            let [a, args] = s:parse_pattern(args, GREP_WORD_PAT)
        else
            let [a, args] = s:parse_pattern(args, ARGUMENT_PAT)
        endif

        call add(list, a)
    endwhile
    return list
endfunction "}}}

function! omg#grep(word, target_files, ...) "{{{
    if a:word == '' || empty(a:target_files)
        return
    endif
    if &modified
        echohl ErrorMsg
        echomsg 'buffer is modified.'
        echohl None
        return
    endif

    let bang = a:0 ? a:1 : 0

    execute
    \   'vimgrep' . (bang ? '!' : '')
    \   a:word
    \   join(a:target_files)
endfunction "}}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
