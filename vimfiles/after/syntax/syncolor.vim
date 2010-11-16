" My preferred colors
hi Normal	guibg=Black guifg=White
hi NonText	gui=bold guibg=Black guifg=Blue
hi Search	guibg=DarkGray guifg=Black
hi Comment	term=bold ctermfg=Cyan cterm=NONE guifg=#00FFFF
hi Constant	term=underline ctermfg=DarkRed guifg=#FF4E4E gui=bold
hi Cursor	guifg=Black guibg=Yellow
hi Special	term=bold ctermfg=Red guifg=#CF90CF
hi Statement	term=bold ctermfg=Yellow guifg=#ffff60 gui=bold
hi PreProc	term=underline ctermfg=LightBlue guifg=#6565FF gui=bold
hi Type		term=underline ctermfg=LightGreen guifg=#60ff60 gui=bold
hi Ignore	ctermfg=Black guifg=bg
hi Error	term=reverse ctermbg=Red ctermfg=White guibg=Red guifg=White
hi Todo		term=standout ctermbg=Yellow ctermfg=Black
			\ guifg=Blue guibg=Orange
hi WildMenu	term=standout ctermfg=Black ctermbg=Yellow
			\ guifg=Black guibg=Orange
hi DiffChange	term=bold ctermfg=Black ctermbg=DarkYellow
			\ guibg=DarkOrange
hi Folded	term=standout cterm=bold ctermfg=Cyan ctermbg=Black
			\ guifg=Cyan guibg=gray20

" Insert popup menu is only available if the terminal supports at least
" 8 colors so it does not make sense to provide 'term' values
hi Pmenu	ctermfg=Black ctermbg=Gray guifg=Black guibg=Gray
hi PmenuSel	ctermfg=Black ctermbg=Yellow guifg=Black guibg=Orange
hi PmenuSbar	ctermbg=Yellow guibg=Orange
hi PmenuThumb	ctermfg=Red guifg=Red
