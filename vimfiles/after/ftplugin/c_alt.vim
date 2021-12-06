nnoremap <silent> <buffer> <LocalLeader>a :call <SID>C_Alternate(0)<CR>
nnoremap <silent> <buffer> <LocalLeader>s :call <SID>C_Alternate(1)<CR>
nnoremap <silent> <buffer> <LocalLeader>w :call <SID>C_Alternate(2)<CR>

if exists("*s:C_Alternate") " Do not define functions twice
  finish
endif

" Switching between source and header files via \a, \s, \w
" If the 'alternative' buffer is alredy open in some window all these macros
" jump to this window, otherwise:
" <LocalLeader>a loads buffer in current window
" <LocalLeader>s splits the window and opens the alternative in the new window
" <LocalLeader>w if there is other window opened jump to that window and load
"    buffer, otherwise it acts like <LocalLeader>s
let s:header_ext = [ ".h", ".hh", ".hpp", ".hxx" ]
let s:source_ext = [ ".c", ".cc", ".cpp", ".cxx" ]
let s:ext_map = { }
for ext in s:header_ext
  let s:ext_map[ext] = s:source_ext
endfor
for ext in s:source_ext
  let s:ext_map[ext] = s:header_ext
endfor

function! s:AltBuf(buf_name, ext)
  for alt_ext in s:ext_map[a:ext]
    let other_buf = bufnr('\C\(^\|/\)' . a:buf_name . alt_ext)
    if other_buf != -1 && buflisted(other_buf)
      return other_buf
    endif
    return -1
  endfor
endfunction

let s:alt_path = { 'inc': 'src', 'src': 'inc', 'source': 'include', 'include': 'source' } 

function! s:AltFile(buf_name, ext)
  for alt_ext in s:ext_map[a:ext]
    let alt_file = a:buf_name . alt_ext
    if filereadable(alt_file)
      return alt_file
    endif
  endfor
  let dir = matchstr(a:buf_name, '\<\(inc\|src\)\ze/')
  if dir != ''
    let path = substitute(a:buf_name, dir, s:alt_path[dir], "")
    for alt_ext in s:ext_map[a:ext]
      let alt_file = path . alt_ext
      if filereadable(alt_file)
        return alt_file
      endif
    endfor
  endif
  return ''
endfunction

function! s:GoOtherWin(src_win)
  if winnr('$') == 1
    return
  endif
  wincmd w
  while winnr() != a:src_win
    if &previewwindow || &buftype =~ 'quickfix\|help'
      wincmd w
    else
      break
    endif
  endwhile
endfunction

function! s:C_Alternate(win)
  let buf_name = expand("%:t:r")
  let ext = '.' . expand("%:e")
  if ! has_key(s:ext_map, ext)
    return
  endif
  let other_buf = s:AltBuf(buf_name, ext)
  if other_buf != -1
    let other_win = bufwinnr(other_buf)
    if other_win != -1
      exe other_win . "wincmd w"
    else
      if a:win == 0 " Open in the same window
	exe other_buf . "buffer"
      elseif a:win == 1 " Split window and load alternate buffer
	exe other_buf . "sbuffer"
      else " Go to other window and load buffer (if the only window do split)
	let src_win = winnr()
	call s:GoOtherWin(src_win)
	if winnr() == src_win
	  exe other_buf . "sbuffer"
	else
	  exe other_buf . "buffer"
	endif
      endif
    endif
  else " No alternate buffer loaded try to find it on disk
    let alt_file = s:AltFile(expand("%:r"), ext)
    if alt_file != ''
      if a:win == 0 " Open in the same window
        exe "edit " . alt_file
      elseif a:win == 1 " Split window and load
        exe "split " . alt_file
      else " Go to other window and load (if the only window do split)
	let src_win = winnr()
	call s:GoOtherWin(src_win)
	if winnr() == src_win
          exe "split " . alt_file
        else
          exe "edit " . alt_file
        endif
      endif
    endif
  endif
endfunction
