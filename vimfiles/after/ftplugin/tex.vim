" Last modified:  Tue Mar 06, 23:03 (2007)

compiler tex-draft

" I'm using ':' in tagnames eg. \label{fig:somefig} and I want to
" be able to complete this
setlocal isk+=: sw=2 mp=make fdm=indent

" Usefull abbrevs
iabbrev <buffer> ... \ldots
iabbrev <buffer> <-> \leftrightarrow
iabbrev <buffer> -> \rightarrow

" I could catch space and return space or tilde but that way the abbreviations
" would not be expanded so instead I reinsert that space (possibly causing
" expansion of abbrevs) and later backspace it and put tilde (when needed)
inoremap <silent> <buffer> <Space> <Space><C-R>=<SID>TeXSpace()<CR>
if !exists("*s:TeXSpace")
  function s:TeXSpace()
    let place = strpart(getline(line('.')), col('.') - 4, 3)
    if place =~? '^\([ ~({\[]\?[aiouwz]\|\u\.\) $'
	 return "\<BS>~"
    end
    return ""
  endfun
endif

" Higlight text and press <LocalLeader>e for \emph{...}, b -> \textbf,
" i -> \textit ... WARNING: I'm using here my 'pastetoggle' which is <F10>
vnoremap <buffer> <LocalLeader>e <F10><Esc>`>a}<Esc>`<i\emph{<Esc><F10>
vnoremap <buffer> <LocalLeader>b <F10><Esc>`>a}<Esc>`<i\textbf{<Esc><F10>
vnoremap <buffer> <LocalLeader>i <F10><Esc>`>a}<Esc>`<i\textit{<Esc><F10>
vnoremap <buffer> <LocalLeader>l <F10><Esc>`>a}<Esc>`<i\textsl{<Esc><F10>
vnoremap <buffer> <LocalLeader>f <F10><Esc>`>a}<Esc>`<i\textsf{<Esc><F10>

" <F8> starts the viewer
if strlen($DISPLAY)
    noremap <buffer> <F8> :!xdvi %:r&<CR>
else
    noremap <buffer> <F8> :!dvisvga %:r<CR>
endif
