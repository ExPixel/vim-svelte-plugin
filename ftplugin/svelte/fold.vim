"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Config {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:use_foldexpr = exists("g:vim_svelte_plugin_use_foldexpr") 
      \ && g:vim_svelte_plugin_use_foldexpr == 1
"}}}

if !s:use_foldexr | finish | endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Settings {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
setlocal foldmethod=expr
setlocal foldexpr=GetSvelteFold(v:lnum)
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Variables {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:empty_line = '\v^\s*$'
let s:block_end = '\v^\s*}|]|\)'
let s:svelte_tag_start = '\v^\<(script|style)' 
let s:svelte_tag_end = '\v^\<\/(script|style)' 
"}}}

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"
" Functions {{{
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"  see :h fold-expr
"  value			    meaning
"  0			        the line is not in a fold
"  1, 2, ..		    the line is in a fold with this level
"  -1			        the fold level is undefined, use the fold level of a
"			            line before or after this line, whichever is the
"			            lowest.
"  "="			      use fold level from the previous line
"  "a1", "a2", ..	add one, two, .. to the fold level of the previous
"			            line, use the result for the current line
"  "s1", "s2", ..	subtract one, two, .. from the fold level of the
"  ">1", ">2", ..	a fold with this level starts at this line
"  "<1", "<2", ..	a fold with this level ends at this line
function! GetSvelteFold(lnum)
  let this_line = getline(a:lnum)
  let next_line = getline(a:lnum + 1)
  if a:lnum > 1
    let prev_line = getline(a:lnum - 1)
  endif

  " Handle empty or comment lines
  if this_line =~ s:empty_line
    return -1
  endif
  if this_line =~ s:svelte_tag_start
    return '>1'
  endif
  if this_line =~ s:svelte_tag_end
    return '<1'
  endif

  " Use (indentLevel + 1) as fold level
  let this_indent = s:IndentLevel(a:lnum)
  let next_indent = s:IndentLevel(s:NextNonBlankLine(a:lnum))

  if a:lnum > 1
    let prev_indent = s:IndentLevel(a:lnum - 1)

    if this_line =~ s:block_end && (this_indent < prev_indent)
      return prev_indent
    endif
  endif

  if this_indent >= next_indent 
    return this_indent
  elseif this_indent < next_indent
    return '>'.next_indent
  endif
endfunction

function! s:IndentLevel(lnum)
  " Add 1 to enable svelte tags to fold
  return indent(a:lnum) / &shiftwidth + 1
endfunction

function! s:NextNonBlankLine(lnum)
  let next_line = a:lnum + 1
  let last_line = line('$')

  while next_line <= last_line
    if getline(next_line) =~ '\v\S'
      return next_line
    endif

    let next_line += 1
  endwhile

  return 0
endfunction
"}}}
" vim: fdm=marker
