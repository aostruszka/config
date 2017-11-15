setlocal sw=4 tw=80 expandtab

" Minor tweaks to default style
setlocal cino=(0,Ws

" Mapping which prints current context function (it is enough for my
" coding style)
nmap <silent> <buffer> <Leader>f :?^{??^\k? mark t\|
	\call histdel("/",-1)\|let @/ = histget("/", -1)\|echo getline("'t")<CR>

" vi: set tw=80:
