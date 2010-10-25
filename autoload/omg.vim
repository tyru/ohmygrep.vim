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

function! s:internal_error(msg) "{{{
    return 'omg: internal error: ' . a:msg
endfunction "}}}

function! s:lookup_var(varname, ...) "{{{
    for ns in [b:, w:, t:, g:]
        if has_key(ns, a:varname)
            return ns[a:varname]
        endif
    endfor
    if a:0
        return a:1
    else
        throw s:internal_error("cannot find variable '" . a:varname . "'.")
    endif
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

    if len(args_list) == 1
        " :OMGrep {pattern}
        let [word, flags] = s:split_grep_pattern(args_list[0])
        let files = deepcopy(s:lookup_var('omg_default_files'))
    else
        " :OMGrep {files}[, {more files}] {pattern}
        let [word, flags] = s:split_grep_pattern(args_list[-1])
        let files = args_list[: -2]
    endif
    if a:bang
        let flags .= '!'
    endif
    if flags == ''
        let flags = g:omg_default_flags
    endif

    call omg#grep(word, flags, files)
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
    let GREP_WORD_PAT = '^/\(.\{-}[^\\]\)/\(\S*\)$' . '\C'
    let m = matchlist(a:args, GREP_WORD_PAT)
    if !empty(m)
        return [m[1], m[2]]
    else
        return [a:args, '']
    endif
endfunction "}}}

function! s:grep_parse_args(args) "{{{
    let GREP_WORD_PAT = '^/.\{-}[^\\]/\S*' . '\C'
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

function! s:flatten(list) "{{{
    let ret = []
    for l in a:list
        if type(l) == type([])
            call extend(ret, s:flatten(l))
        else
            call add(ret, l)
        endif
    endfor
    return ret
endfunction "}}}

function! omg#grep(word, flags, target_files) "{{{
    let word = a:word
    if word == '' || empty(a:target_files)
        return
    endif
    let bang = stridx(a:flags, '!') != -1
    if &modified && !bang
        echohl ErrorMsg
        echomsg 'buffer is modified.'
        echohl None
        return
    endif

    let ic = stridx(a:flags, 'i') != -1
    let no_ic = stridx(a:flags, 'I') != -1
    if ic && no_ic
        echohl ErrorMsg
        echomsg 'i and I flags cannot be used together.'
        echohl None
        return
    elseif ic || no_ic
        let word = word
        \   . (ic ? '\c' : '')
        \   . (no_ic ? '\C' : '')
    endif
    let builtin_flags = join(filter(split(a:flags, '\zs'), 'v:val =~# "^[gj]$"'), '')


    let files = a:target_files
    if !empty(g:omg_ignore_basename)
        " Expand globs to actual filenames
        " to exclude ignore files.
        let files = s:flatten(map(files, 'split(expand(v:val), "\n")'))
        for basename in g:omg_ignore_basename
            let files = filter(files, 'fnamemodify(v:val, ":t") !=# basename && filereadable(v:val)')
        endfor
    endif

    try
        if g:omg_use_vimgrep
            silent execute
            \   'vimgrep' . (bang ? '!' : '')
            \   '/' . word . '/' . builtin_flags
            \   join(files)
        else
            silent execute
            \   'grep' . (bang ? '!' : '')
            \   word
            \   join(files)
        endif
        let @/ = word
    catch /E480:/    " No match
        echohl WarningMsg
        echomsg "ohmygrep: No match: '" . word . "'"
        echohl None
    catch
        echohl ErrorMsg
        echomsg v:exception v:throwpoint
        echohl None
    endtry
endfunction "}}}



" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
