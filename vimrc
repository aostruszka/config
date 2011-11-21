" Vim startup file by
" Author: Andrzej M. Ostruszka
" $Id$

if version < 700
  echo "Get a newer vim :)), this startup file probably won't work!"
  sleep 2		" I'm insisting on keeping up to date :))
  q			" But you can override this with `vim -u NONE'
endif

behave xterm		" This is what I'm used to :))
set incsearch		" This is for a try - maybe I'll like it :)
set hlsearch		" Let's try highlighting of search pattern
set nocompatible	" Use Vim defaults (much better!)
set cpoptions-=a	" Don't set alternate file name when :read 'ing files
set nostartofline	" Do not change column when `moving around'
set bs=indent,eol,start " Allow backspacing over everything in insert mode
set whichwrap+=<,>,[,]  " Allow to wrap with cursor keys
set nowrap		" Don't wrap long lines
set display=lastline	" and show as much as possible of the last line
			" (instead of displaying @ for long lines)
set joinspaces		" I used to prefer \frenchspacing (in TeX parlance :))
			" since this is polish typography rule but using two
			" spaces gives more information about the "structure"
set cpoptions+=J	" so I also include J in cpoptions
set autoindent		" Default autoindenting
set textwidth=72	" Default width of text
set shiftwidth=2	" Indent 2 spaces
set shiftround		" Round indent to multiple of 'sw' (> and < commands)
set showmatch		" Show corresponding bracket while closing
set formatoptions=12tcql " Global formatting options
set comments=sr:/*,mb:*,ex:*/,://,b:#,:%,n:>,fb:-
set backup		" Keep a backup files,
set backupdir=~/.vim-backup,~/tmp,.	" but store them in these directories
set history=50          " Keep 50 lines of cmd_line history (also used
			" as a default for various options in viminfo)
set viminfo='50,\"50	" Read/write a .viminfo file, don't store more
			" than 50 lines of registers
set pastetoggle=<F10>	" Switch between paste/nopaste via <F10>
set ruler		" Use ruler
set hidden		" Allow switching between buffers without '!'
set helpheight=15	" Minimal help window height
set lazyredraw		" Do not update screen while executing macros etc.
set mousemodel=extend	" Extend selection with right mouse (like in xterm)
if &term=~"xterm"
  " I often use `global' clipboard but if I set this in Linux console I'm
  " not able to use it. In xterm I can do this by keeping Shift pressed.
  "FIXME: Somehow this does not work in cygwin (without X running) - think
  "about some workaround
  "set mouse=a		" maybe with time I'll get used to using mouse :))
endif
set mousehide		" Hide the mouse pointer while typing
set showcmd		" Show partial commands in status line
set grepprg=grep\ -nH	" Force line numbers and filename output
set splitbelow		" I prefer to view new buffers/file in lower part
set splitright		" and to the right when using :vsplit and other
set switchbuf=useopen   " When switching check if it isn't already opened
set wildmenu		" Use completion menu (this is for command line only,
			" for insert completion see completeopt below)
set suffixes+=.log,.aux,.eps,.ps " push these to the end of the completion list
set wildignore+=*.o,*.obj,*~,*.dvi,*.cm* " completely ignore these
set wildmode=longest:full,full	" I like enhanced completion
set complete-=i		" I don't want to search all system include files on
			" every completion so I remove 'i' from the default
			" settings ".,w,b,u,t,i"
set completeopt=longest,menu,preview " For insert completions use longest, show
			" a popup menu and details in preview (if opened)
set foldminlines=2	" What is the point in having 1 line (default) fold?
set listchars+=tab:>-	" For 'list' I prefer tabs to be ">-------" than ^I
set virtualedit=block   " Allow selection of the block beyond the end of lines

if !has("unix")
  " I use cygwin zsh/bash as a shell so I need to set this
  set shellslash
endif

" ---------------  Specific stuff for Polish language -------------
" This should make my life easier since I'm editing in these charsets and
" in theory they should be guessed automatically.  But this is a theory, the
" problem is that if I start to edit ascii file that will set fenc=cp1250 and
" this is not what I want (since I might add some accented characters and they
" will be converted to cp1250 :( - instead of iso).  So instead of just doing
" set fileencodings=ucs-bom,cp1250,cp852,iso-8859-2
" I make a shortcut for setting it
command! -nargs=? PLchsets call PLchsets(<f-args>)
function! PLchsets(...)
  if a:0 && a:1 =~? 'off'
    set fencs&vim
  else
    set fencs=ucs-bom,cp1250,cp852,iso-8859-2
  endif
endfun

" In addition to the above you can also use the below and place "exrc" in the
" directory of the DOS/Windows files setting the appropriate fencs
"set secure
"set exrc

" In any environment that supports Polish locale I'm setting it properly in my
" profile so the only situation where this needs to be set is when there's no
" support for locale.  In that case I'm adding Polish diacritical characters to
" the default vim setting - only those that are not included already (ÆæÊêÑñÓó
" are in the 192-255 range)
if $LC_CTYPE=='C'
  set iskeyword+=¡,±,£,³,¦,¶,¯,¿,¬,¼
endif

" -----------------------------------------------------------------

" Syntax highlighting stuff
if &t_Co > 2 || has("gui_running")
  set background=dark		" I always use black background :))
  let c_space_errors=1
  syntax on
  " This command highlights any part sticking out beyond 'tw'.  You can clear it
  " with :match none
  command! RightMargin if &tw>0 | exe 'match NonText /.\%>'. &tw .'v./' | end

  " I often use these in "normal text files"
  command! Fixme syn keyword Todo TODO FIXME NOTE XXX contained
endif

" GUI specific stuff (I don't use .gvimrc)
if has("gui_running")
  if has("unix")
    if has("gui_gtk2")
      " It seems that in GTK2 this is equivalent of the below lengthy font name
      set guifont=Fixed\ 11,Mono\ 12
    else
      set guifont=-misc-fixed-medium-r-normal-*-*-140-*-*-c-*-iso8859-2
    endif
    " Show man pages in separate xterm window
    set keywordprg=xterm\ -e\ man
  else
    set guifont=Lucida_Console:h11:cEASTEUROPE
    " This will cause gui to start maximized
    au GUIEnter * simalt ~x
  endif

  set guioptions-=T " I don't remember myself using a toolbar.
  set guioptions-=m " The same for menu

  " I want to be able to map ALT key sequences
  set winaltkeys=no

  " I'm protecting myself against changes in system configuration
  set ch=1
endif

" These are the global cscope settings that don't conflict with other file types
if has("cscope")
  set csqf=s-,c-,d-,i-,t-,e-	" Use quickfix for cscope searching
  set csverb	" Make the cscope verbose
  " For unknown reasons :cs add does not complete on file names and does
  " not allow more then 1 database so I fix this via my own :CSadd command
  " Update: in 7.0 it looks like ":cs add" completes on file names but I still
  " can't add multiple databases as the second file name is used as a prefix.
  function! s:CSAddAll(...)
    set cst	" CTRL-] and tag performs cstag
    set csto=1	" First search using cscope
    let i = 1
    while i <= a:0
      if filereadable(expand(a:{i})) || filereadable(expand(a:{i}) . "/cscope.out")
	execute "cs add " . expand(a:{i})
      endif
      let i = i + 1
    endwhile
  endfun
  command! -nargs=+ -complete=file CSadd call <SID>CSAddAll(<f-args>)
endif

" =============== GLOBAL COMMANDS, MAPPINGS AND ABBREVIATIONS ===============
" Convinient shortcut, by default :u is 'undo' which is never the way I undo
" changes - I always do that from the normal mode.  So I make an abbreviation
" for this (upper case also because I often do not manage to release the shift
" from ':' when pressing 'u' :))
cnoreabbrev u update
cnoreabbrev U update

" Replace the selected text with the " register. (Note: it almost is the same as
" in example rc file but I prefer to use 's' vmode instead of 'd' and then 'i')
vnoremap p <Esc>:let current_reg = @"<CR>gvs<C-R>=current_reg<CR><Esc>

" Turn of highlighting
noremap <silent> <Leader>h :nohl<CR>

" I prefer Y to behave like D and C
noremap Y y$

" It is more comfortable to use ' instead of ` but the later is better :))
noremap ' `

" I'm used to these bash-like bindings
inoremap <M-Backspace> <C-W>
inoremap <M-d> <C-O>dw

" These are similar (but more Windows like)
inoremap <C-BS> <C-W>
inoremap <C-Del> <C-O>dw

" These are more handy than going off the insert mode moving left/right and
" starting insert mode again - moreover I don't have to move my hand of the
" home row :) (mnemonic: think what bash/zsh does :))
inoremap <C-F> <Right>
inoremap <C-B> <Left>

" <F1> - help on current WORD
" I never use help.txt since usually I can find topic much faster by guessing
" the proper tag for it
noremap <F1> :help <C-R>=expand('<cWORD>')<CR><CR>
imap <F1> <C-O><F1>

" <F2> - save (only when modified)
noremap <F2> :update<CR>
imap <F2> <C-O><F2>

" <F9> - run make
nmap <F9> <F2>:make<CR>

" Switching between buffers (<C-N> and <C-P> are valid commands but I'm not
" using them (I'm using standard vi j,k and cursor keys)
noremap <C-N> :bn<CR>
noremap <C-P> :bp<CR>

" Current date
iab dmY <C-R>=strftime("%d.%m.%Y")<CR>

" =============== AUTOCOMMANDS ===============
if has("autocmd")
  filetype plugin indent on

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  autocmd BufReadPost *
      	\ if line("'\"") > 0 && line("'\"") <= line("$") |
      	\   exe "normal g`\"" |
      	\ endif

  " Automatic 'last modified' time stamp when present in first
  " and last 20 lines
  autocmd BufWritePre,FileWritePre * kt | keepjumps call LastMod() | 't
  function! LastMod()
    if !&modifiable | return | endif
    let l = 20
    if line("$") < 2*l
      exe "%s/\\(\\A*\\)Last modified:.*/\\1Last modified: "
        \ strftime("%a %b %d, %H:%M (%Y)") . "/e"
    else
      exe "1," . l . "s/\\(\\A*\\)Last modified:.*/\\1Last modified: "
        \ strftime("%a %b %d, %H:%M (%Y)") . "/e"
      exe "$-" . l . ",$s/\\(\\A*\\)Last modified:.*/\\1Last modified: "
        \ strftime("%a %b %d, %H:%M (%Y)") . "/e"
    endif
    call histdel("/",-1)
  endfun

  " I don't want to have separate ftplugin just for one command
  " fo-=l is for 'mail' cause it is set in default ftplugin :(
  autocmd FileType cvs,crontab,mail	setlocal nobackup fo-=l

  " TODO: find some reasonable template system and remove the below
  augroup cprog
  " Remove all cprog autocommands
  au!
  " Use templates for new files
  au BufNewFile main.c	r ~/.vim/templ/main.c|-d
  au BufNewFile *.h		r ~/.vim/templ/c-head|-d|
          \do FileReadPost c-head
  au FileReadPost c-head exe 'g/<header_file>/s##\U'.expand("%:t:r")
  augroup END

  augroup tex
  au!
  au BufNewFile *.tex		r ~/.vim/templ/tex|-d
  augroup END

  augroup html
  au!
  au BufNewFile *.html	r ~/.vim/templ/html|-d
  augroup END

  augroup make
  au!
  au BufNewFile Makefile	r ~/.vim/templ/make|-d
  augroup END

endif " has("autocmd")
" vim: set sw=2 tw=80:
