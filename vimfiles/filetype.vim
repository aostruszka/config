if exists("did_load_filetypes")
  finish
endif

augroup filetypedetect
  au! BufNewFile,BufRead *.dxl,*.inc	setfiletype dxl
  au! BufNewFile,BufRead *.ml4		setfiletype ocaml
augroup END
