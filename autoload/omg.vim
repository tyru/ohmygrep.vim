" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('s:loaded') && s:loaded
    finish
endif
let s:loaded = 1
" }}}
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

function! s:grep_parse_args(args, default_flags) "{{{
    let GREP_WORD_PAT = '^/\(.\{-}[^\\]\)/\([gj]*\)'
    let args = a:args
    let list = []
    while args != ''
        let args = parse_args#skip_white(args)

        if args =~# GREP_WORD_PAT
            let [a, args] = parse_args#parse_pattern(args, GREP_WORD_PAT)
        else
            let [a, args] = parse_args#parse_one_arg_from_q_args(args)
        endif

        call add(list, a)
    endwhile
    return list
endfunction "}}}

function! omg#grep(word, target_files, ...) "{{{
    if a:word == '' || empty(a:target_files)
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
