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
        let args_list = s:grep_parse_args(a:args)
    catch /^parse error$/
        echohl WarningMsg
        echomsg v:exception
        echohl None
        return
    endtry

    if empty(args_list)
        " :OMGrep
        let [word, flags] = [@/, g:omg_default_flags]
        let files = deepcopy(g:omg_default_files)
    elseif len(args_list) == 1
        " :OMGrep {pattern}
        let [word, flags] = s:split_grep_pattern(args_list[0])
        let files = deepcopy(g:omg_default_files)
    else
        " :OMGrep {files}[, {more files}] {pattern}
        let [word, flags] = s:split_grep_pattern(args_list[-1])
        let files = args_list[: -2]
    endif

    call omg#grep(word, flags, files, a:bang)
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

function! s:split_grep_pattern(args) "{{{
    let GREP_WORD_PAT = '^/\(.\{-}[^\\]\)/\([gj]*\)$' . '\C'
    let m = matchlist(a:args, GREP_WORD_PAT)
    if !empty(m)
        return [m[1], m[2]]
    else
        return [a:args, '']
    endif
endfunction "}}}

function! s:grep_parse_args(args) "{{{
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

function! omg#grep(word, flags, target_files, ...) "{{{
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

    try
        execute
        \   'vimgrep' . (bang ? '!' : '')
        \   '/' . a:word . '/' . a:flags
        \   join(a:target_files)
        let @/ = a:word
    catch
        echohl ErrorMsg
        echomsg v:exception v:throwpoint
        echohl None
    endtry
endfunction "}}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
