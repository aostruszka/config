" Author: Andrzej M. Ostruszka
" Last modified:  Wed Jun 24, 13:19 (2009)

setlocal sw=4 tw=80 expandtab

" ---------------------- PERSONAL STYLE ---------------------------
setlocal cino=(0,Ws

if exists("b:amo_owned_code")
  " I prefer to use 2 spaces for the initial indent - it's trivial to see that
  " we are not on global level anyway so no need for more.
  setlocal cino=^-2,g2,h2
  let b:ini_shift_add=2	" See the description of this var below
endif

" ---------------------- FOLDING ---------------------------
" This variable is used to adapt folding to the current indentation scheme (see
" below).  This is the amount of indent that should be added to the initial
" indentation in order to reach the value of 'shiftwidth' and thus be regarded
" as larger indentation level: e.g. if one uses 2 spaces for the highest level
" indentation of the functions code and sw=4 then setting this var to 2 will
" fold the whole function.
let b:ini_shift_add=0

" This function does nearly the same as fdm=indent with some minor tweaks :))
" I could use cindent here but this one is simplier and most of all I expect one
" to rely on the vim's indenting (see help for 'cinoptions' if you're not
" satisfied with the default setting) - see also the description of the
" b:ini_shift_add
function! AMO_C_fold(lnum)
  let cur_lnb = prevnonblank(a:lnum - 1)
  let add_lev = 0
  " This is the reason for this function - I prefer the cpp macro after the
  " opening { to be of the folding level of block contents instead of the brace
  " itself as default fdm=indent does.  This is far from perfect but good
  " enough to be exported :)).
  while getline(cur_lnb) =~ '^\s*#'
    let cur_lnb = prevnonblank(cur_lnb - 1)
  endw
  if getline(cur_lnb) =~ '{'
    let add_lev = 1
  end
  let lev = (indent(cur_lnb)+b:ini_shift_add)/&sw
  return lev + add_lev 
endfun
  
" Yes I know, what's the point of the function above when I use fdm=indent :).
" Well the point is that most of the time I don't have to deal with ugly code
" with lots of cpp macros so the default is enough and I just want to be able to
" switch easily (by 'setl fdm=expr' only)
setlocal fdm=indent foldexpr=AMO_C_fold(v:lnum)

" ---------------------- MAPPINGS ---------------------------

" Mapping which prints current context function (it is enough for my
" coding style)
nmap <silent> <buffer> <Leader>f :?^{??^\k? mark t\|
	\call histdel("/",-1)\|let @/ = histget("/", -1)\|echo getline("'t")<CR>

" Comment visual block (there are better solutions but this one is
" good enough for me)
vnoremap <buffer> <Leader>c <Esc>`>a*/<Esc>`<i/*<Esc>

" Uncomment block you're inside
noremap <buffer> <Leader>C [*2x]*h2x

" Goto local definition - I'm using this because I used to do gd to find
" out the type of given var jump to the definition via CTRL-] browse in
" there go back via CTRL-T and I wanted to be able to jump back to the
" initial position easily but unfortunately CTRL-O would go back through
" the whole jump history instead of going to where I've started.  To go
" back just jump to mark v.  Mnemonics: \d -> goto definition (I'm using
" standard <Leader>) and `v -> go back to the variable (I could use mark
" 'd for it but I prefer to leave marks from the beginning of the
" alphabet intact :)). 
noremap <buffer> <Leader>d mvgd

" vi: set tw=80:
