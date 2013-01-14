# .zshrc
# Author: Andrzej M. Ostruszka
# $Id: zshrc 104 2010-10-25 15:37:50Z aao014 $

# User specific aliases and functions

# load_user_profile_ set means that we should source the ~/.zprofile.
# I set it in the cases where I cannot start zsh as a login shell cause
# I have to omit invalid/harmful system /etc/z{env,profile} etc. but the user
# profile should indeed be loaded.

if [[ -n $load_user_profile_ ]]; then
    . ~/.zprofile
    unset load_user_profile_
fi

if [[ -o interactive ]]; then	# if shell is interactive

  # Options 
  set -o no_list_packed	# Align entries for listings
  set -o no_hup		# Do not send the SIGHUP to the background jobs on exit
  set -o bsd_echo	# I don't want \b \f \v and so on interpreted by default
  			# (use -e echo option to enable them or 'print' builtin)

  # History related options/commands
  set -o hist_ignore_all_dups hist_no_functions hist_no_store
  HISTFILE=~/.zhistory
  HISTSIZE=1000 # Internal history list size
  SAVEHIST=$HISTSIZE # Number of entries stored in HISTFILE
  FCEDIT="vim -u NONE" # fc editing is usually very "primitive" so to speed up
		       # vim startup I skip my configuration file
  # Set up the LS_COLORS variable - do it early so that its value can be use in
  # zstyle completions (see below)
  if type -w dircolors > /dev/null; then
    if test -r $HOME/.dir_colors; then
      eval $(dircolors -b $HOME/.dir_colors)	# colorize output of ls
    elif test -r /etc/DIR_COLORS; then
      eval $(dircolors -b /etc/DIR_COLORS)
    fi # if none available use the precompiled values
  fi

  # Keybindings and so on (sometimes the terminal is so dumb - e.g. 'sun' - that
  # it has many keys missing in the terminfo database, so I've added additional
  # checks for the presense of the key to avoid warnings on startup)
  
  [ -n $terminfo[kbs] ] && stty erase $terminfo[kbs]
  # Usually ^S is bound to stop key but I don't use this feature that often so
  # I turn it off and remember the original setting in case I need it - just do
  # stty stop $stop_key start $start_key.  This assumes GNU like stty output.
  stop_key=${${${(f)$(stty -a)}#*stop = }%%;*}
  # Accordingly for the start key
  start_key=${${${(f)$(stty -a)}#*start = }%%;*}
  stty stop undef start undef

  # My beloved editor is vim and I want to have vi like bindings also in shell.
  # But not many people are used to that so if I want to give control over
  # terminal I prefer to switch to emacs mode - and they will probably
  # appreciate to have it confiugred :))
  # Use "bindkey -(e|v)" to switch to (emacs|viins) map and link it to main.

  bindkey -v

  # Home, end and delete keys (one can also use `tput' external command)
  [ -n $terminfo[khome] ] && bindkey -M emacs $terminfo[khome] beginning-of-line
  [ -n $terminfo[kend] ] && bindkey -M emacs $terminfo[kend] end-of-line
  [ -n $terminfo[kdch1] ] && bindkey -M emacs $terminfo[kdch1] delete-char
  # Left/Right arrows
  [ -n $terminfo[kcuf1] ] && bindkey -M emacs $terminfo[kcuf1] forward-char
  [ -n $terminfo[kcub1] ] && bindkey -M emacs $terminfo[kcub1] backward-char

  # By default the \M-p and \M-n search backward and forward with only first
  # word in line (history-search-forward/backward widgets) but I prefer to
  # search for lines beginning with the current line up to the cursor.
  bindkey -M emacs '^[p' history-beginning-search-backward
  bindkey -M emacs '^[n' history-beginning-search-forward

  # But these first word searches can be useful so I bound them to the Up/Down
  # arrow keys - by default they are bound to up/down-line-or-history but this
  # functions are also bound to ^P/^N which are more convenient for me (I'm
  # a touch typing vim maniac :) - with CapsLock mapped to Ctrl in
  # every computer/system I work).
  [ -n $terminfo[kcuu1] ] && bindkey -M emacs $terminfo[kcuu1] history-search-backward
  [ -n $terminfo[kcud1] ] && bindkey -M emacs $terminfo[kcud1] history-search-forward

  # PageUp, PageDown - they are not used so why not to bind them to something.
  # For now these are set to values I've seen in /etc/zshrc (in PLD linux
  # distribution):
  # PageUp -> up-history (useful when you have multiline commands - then PageUp
  #    will move to the previous command)
  # PageDown -> end-of-history (useful when you start searching and decide to
  #    get back to the original - supposedly the last in history :))
  [ -n $terminfo[kpp] ] && bindkey -M emacs $terminfo[kpp] up-history
  [ -n $terminfo[knp] ] && bindkey -M emacs $terminfo[knp] end-of-history

  # From unknown (yet to me) reason zsh ouput's ^[[{A,B,C,D} for
  # Arrow{Up,Down,Righ,Left} even when it differs from the terminfo settings:
  # e.g. ^[O{A,B,C,D} so I remap them here in case they differ
  if [[ -n $terminfo[kcuu1] && $terminfo[kcuu1] != $'\e[A' ]]; then
    bindkey -s '^[[A' $terminfo[kcuu1]
    bindkey -s '^[[B' $terminfo[kcud1]
    bindkey -s '^[[C' $terminfo[kcuf1]
    bindkey -s '^[[D' $terminfo[kcub1]
  fi

  # ^Q is more convenient than the default ^X^V (usually it is terminal start
  # key but I unbound it above).  It is also by default push-line but there are
  # other bindings to it (\E-q \E-Q and \M-q \M-Q if you install default meta
  # binings via "bindkey -m")
  bindkey -M emacs '^Q' vi-cmd-mode

  # And now some settings to make vi(ins|cmd) mode better :).  I always try to
  # be explicit for the mode the mapping is done since it allows easier
  # switching of the default mode - in case someone tries to use this file for
  # his/her own purposes :))
  bindkey -M vicmd u undo # vim like incremental undo is better than vi undo
  # so far I had no need for redisplay so I make this vim like binding
  bindkey -M vicmd '^R' redo
  bindkey -M viins '^A' beginning-of-line
  if [ -n $terminfo[khome] ]; then
    bindkey -M viins $terminfo[khome] beginning-of-line
    bindkey -M vicmd $terminfo[khome] beginning-of-line
  fi
  bindkey -M viins '^E' end-of-line
  if [ -n $terminfo[kend] ]; then
    bindkey -M viins $terminfo[kend] end-of-line
    bindkey -M vicmd $terminfo[kend] end-of-line
  fi
  bindkey -M viins '^F' vi-forward-char
  bindkey -M viins '^B' vi-backward-char
  # I prefer vim like backspace'ing from the vi original behaviour
  bindkey -M viins '^H' backward-delete-char
  [ -n $terminfo[kbs] ] && bindkey -M viins $terminfo[kbs] backward-delete-char
  # Sometimes it happens to me to use Delete :))
  if [ -n $terminfo[kdch1] ]; then
    bindkey -M viins $terminfo[kdch1] vi-delete-char
    bindkey -M vicmd $terminfo[kdch1] vi-delete-char
  fi
  # Since ^P and ^N are not bound in viins I make use of them for history
  bindkey -M viins '^P' up-history
  bindkey -M viins '^N' down-history
  # These commands I'm so used to that I want them available also in viins
  bindkey -M viins '^[p' history-beginning-search-backward
  bindkey -M viins '^[n' history-beginning-search-forward
  # These two are also handy but I change default binding
  bindkey -M viins '^[P' _history-complete-older
  bindkey -M viins '^[N' _history-complete-newer

  # This one is sometimes handy so I bind it too
  bindkey -M viins '^[q' push-line

  # For other programs that actually use readline library
  export INPUTRC=~/.inputrc	# This should protect me from some damn admins
				# that sets this variable to non-existent file
				# or file that does not include user specific
				# inputrc

  # Prompt: To decipher the setting below it probably would be helpful to know
  # that %{ ...%} is the literal escape sequence which I'm using to color up my
  # prompt.  A sequence of non-printing chars and the color description is
  # a composition of one or more of the following codes:
  # Attribute codes: 
  # 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
  # Color codes:
  # 0=black 1=red 2=green 3=yellow 4=blue 5=magenta 6=cyan 7=white
  # To get foreground/background color add 30/40 (see setaf/setab terminal
  # capabilities - it is not straight forward to decode them since they use
  # parametrized strings.  For my xterm it is:
  # setab=\E[4%p1%dm, setaf=\E[3%p1%dm 
  # so it reads for background:
  # - output \E[4
  # - push param1 on stack
  # - print it as int (printf like format)
  # - ouput m
  # and the parameter is just the color number.  Related to this are setf/setb
  # attributes - see 'man terminfo' - they say there that if terminal supports
  # ANSI escape sequence it should be in setaf/setab otherwise it should be in
  # setf/setb and historically arguments for setf/setb correspond to different
  # color mappings (switched blue<->red and yellow<->cyan numbers).  In my xterm
  # setb reads:
  # setb=\E[4%?%p1%{1}%=	# Output \E[4, push p1 on stack, if it equals 1
  #            %t4		# then ouput 4 (blue remapping)
  #            %e%p1%{3}%=	# elseif it equals 3
  #              %t6		# then output 6 (cyan remapping)
  #              %e%p1%{4}%=	# elsif it equals 4
  #                %t1		# then output 1 (red remapping)
  #                %e%p1%{6}%=	# elseif it equals 6
  #                  %t3	# then output 3 (yellow remapping)
  #                  %e%p1%d%;m	# else output is as %d and 'm'
  #
  # Example: echo -e '\e[04;33;41m  FAILURE  \e[0m' should print an underlined
  # yellow text on a red background.  You can combine the attributes like:
  # echo -e '\e[01;05;36;44m  FAILURE  \e[0m' which should give a bold, blinking
  # cyan text on a blue background.
  #
  # Whether terminal supports given attribute or not is another issue :))
  #
  # Related to the above are XTerm.color0 to XTerm.color15 resources where you
  # can say what exactly you mean by e.g. bold/bright red -> XTerm.color9
  # (think in octal - bold being 010 :))

  # Somehow I like the default setting of bash prompt in cygwin (without
  # the title bar part) so I modified it a bit to suit my taste and made
  # use of couple nice zsh features :) (like truncation of the current directory
  # to 50 characters and conditional # or $ - depending whether the shell is in
  # privileged mode or not; see "info zsh 'Prompt Expansion'" ).
  PS1=$'%{\e[32m%}%n@%{\e[1;32m%}%m %{\e[0;33m%}%50<...<%~%<<%{\e[0m%}\n%(!.#.$) '

# Completion stuff - I want it two be done before my aliases are defined so that
# I can define completion for them also

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' completions 1
zstyle ':completion:*' expand suffix
zstyle ':completion:*' glob 1
zstyle ':completion:*' ignore-parents parent pwd
zstyle ':completion:*' insert-unambiguous false
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-prompt '%SAt %p: Hit TAB for more, or the character to insert%s'
zstyle ':completion:*' list-suffixes true
zstyle ':completion:*' matcher-list '' '+m:{a-z}={A-Z}'
zstyle ':completion:*' max-errors 1 numeric
zstyle ':completion:*' menu select=2
zstyle ':completion:*' original true
zstyle ':completion:*' preserve-prefix '//[^/]##/'
zstyle ':completion:*' prompt 'Possible corrections (%e errors)'
zstyle ':completion:*' select-prompt '%SScrolling active: current selection at %p%s'
zstyle ':completion:*' substitute 1
zstyle ':completion:*' verbose true
zstyle ':completion:*:urls' urls ~/.zsh_local/urls
zstyle :compinstall filename ~/.zshrc

autoload -Uz compinit
compinit
# End of lines added by compinstall

  #
  # Functions and aliases (first the generic ones)
  #

  # Sets the title bar of the xterm/rxvt to the argument supplied.
  titlebar () {
    if [[ $# -lt 1 ]]; then
      echo "You have to give some name! Not changing anything :)"
    else
      echo -ne "\e]0;$*\a" # The version with ^G at the end also works
    fi
  }
  # I don't like xterm title bar to be set automatically to user@host & path or
  # something because I'm using WindowMaker and I navigate between windows using
  # windows list feature (usually bound to F11) and such long titles would make
  # this list hard to read and navigate (they all start with the same letter).
  # So I set for each xterm a meaningfull and short title and thus I'm able to
  # dispatch in the windows list just with a single letter.
  # Besides with a reasonably set prompt there's hardly a need for that feature. 
  # If you prefer to have the automatic titlebar updates define precmd function.
  # One way is through this function :)
  auto_titlebar () {
    case $* in
      on)
	case $TERM in
	  *xterm*|gnome|rxvt)
	    precmd () { print -Pn "\e]0;%n@%m: %~\a" }
	  ;;
	esac
	;;
      off)
	if functions precmd > /dev/null; then unfunction precmd; fi
	;;
      *)
	echo "autotitlebar on|off"
	;;
    esac
  }
  auto_titlebar off

  h() { fc -l -${1:-20} } # List last X (20 by default) commands
  alias p=${PAGER:=less}	# use env var (and set it if empty)
  alias e=${EDITOR:=vim}
  alias ge="gvim --remote-silent"

  alias md=mkdir
  alias pd=pushd
  alias ungzip=gunzip			# I often make such mistake :))
  alias gdb='gdb -q'
  alias bc='bc -q'
  [[ -n $LESSCHARDEF ]] && alias perldoc='LESSCHARSET= perldoc'

  #if type -w pinfo > /dev/null; then alias info=pinfo; fi

  # If there is .screen.session then treat it as config file e.g. to have
  # automatically spawned shell and vim (with saved session)
  # -8<-----
  # source $HOME/.screenrc
  # screen 1
  # screen -t vim 2 vim -S
  # -8<-----
  screen () {
    if [[ -r .screen.session ]]; then
      command screen -c .screen.session $@
    else command screen $@
    fi
  }

  basic_ls_="ls -F --color=tty"
  alias ls="$basic_ls_"
  alias ll="$basic_ls_ -l"
  alias la="$basic_ls_ -A"
  alias lla="$basic_ls_ -lA"
  # -h (human readable :)) option seems to be GNU ls extension but on newer
  # solaris it is also present so I leave it outside case below
  alias llh="$basic_ls_ -lh"
  unset basic_ls_

  case $OSTYPE in
    *linux*)	# Linux specific aliases
      # Switching codes for LAT1_MAP and USER_MAP from
      # /usr/src/linux/Documentation/unicode.txt (in my case USER_MAP is
      # iso8859-2 but I'm mainly using only polish diacritical characters thus
      # the 'pl' prefix in alias :))
      alias plfont="echo -ne '\033(K'"
      alias usfont="echo -ne '\033(B'"
      # This one is inspired by cygwin's cygrun alias (I got used to it
      # so much that I had to find linux equivalent :D)
      if type -w xdg-open > /dev/null; then alias xo=xdg-open; fi
      ;;
    *cygwin*)
      # On windows I sometimes don't start X server and use this alias
      # to launch xterm with vim (Note: in zsh &! and &| when used instead of
      # just & mean "run in background and disown this job automatically")
      alias xvim="rxvt -T VIM +sb -sl 0 -geometry 95x37 -e ${EDITOR} &!"
      # Normally I want a fullscreen X root window ...
      alias runx='startx -- -fullscreen -clipboard -xkbrules xorg -xkbmodel pc104 -xkblayout pl -xkboptions "ctrl:nocaps" > ~/.xsession-errors 2>&1 &!'
      # ... but this gives problems with remote desktop and others so this one
      # is also handy
      runx_multi() {
	XWin -multiwindow -clipboard -xkbrules xorg -xkbmodel pc104 -xkblayout pl -xkboptions "ctrl:nocaps" &> ~/.xsession-errors &!
	# Wait until X server starts up
	if [[ -z $DISPLAY ]]; then
	  export DISPLAY=:0
	fi
	until xset q &> /dev/null; do sleep 1; done
        if [ -d ~/.fonts ]; then
          xset +fp $HOME/.fonts
        fi
        xrdb -DPOLISH_LOCALE=${POLISH_LOCALE:-0} -load $HOME/.Xdefaults
        xterm -ls &!
      }
      # another ones specific for windows :) - open the specified
      # document/link/... in Windows registered application
      alias cygrun='cygstart --showmaximized'
      alias xo=cygrun
      # Complete files for these two (I need to quote cygrun cause alias
      # expansion is done very early - after history expansion which is done
      # first)
      compdef _files 'cygrun' cygstart 'xo'
      # Default mount poing in cygwin is /cygdrive but I prefer /win, however
      # sometimes people take it for granted that it is /cygdrive so I have this
      # convenient toggle
      toggle_mount() {
	case $(mount -p) in
	  */win*) mount -c /cygdrive && cd ${$(pwd)/win/cygdrive}
	    ;;
	  */cygdrive*) mount -c /win && cd ${$(pwd)/cygdrive/win}
	    ;;
	esac
      }
      # Somehow I have problems with borders in mc under cygwin so I use ascii
      if type -w mc > /dev/null; then alias mc='\mc -a -d -c'; fi
      ;;
    *solaris*)
    ;;
  esac

  if [ -r ~/.zsh_local/zshrc ]; then	# Host specific settings
    . ~/.zsh_local/zshrc
  fi
fi


# vim: set sw=2 tw=80:
