" For ClearCase "version extended" file names
augroup filetypedetect
  au BufNewFile,BufRead */*@@*
    \ if expand("<afile>") =~ '@@' |
    \   exe "doau filetypedetect BufRead " . expand("<afile>:s?@@.*$??")|
    \ endif
augroup END 
