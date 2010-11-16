# .bashrc
# Author: Andrzej M. Ostruszka
# $Id: bashrc 98 2008-11-12 11:18:53Z aao014 $

# User specific aliases and functions

# load_user_profile_ set means that we should source the ~/.bash_profile e.g.
# I set it in the cases where I cannot start bash with --login option cause
# I have to omit invalid/harmful system /etc/profile etc. but the user profile
# should indeed be loaded.  I also use it in my .xinitrc/.xsession in order to
# load env vars for the whole X session.

if [ "$load_user_profile_" ]; then
    . ~/.bash_profile
    unset load_user_profile_
fi

# Source global definitions
if [ -r /etc/bashrc ]; then
    . /etc/bashrc
fi
if [ -r /etc/bash.bashrc ]; then
    . /etc/bash.bashrc
fi

if [[ $- == *i* ]]; then	# if shell is interactive
    # Force consistency between terminal settings and the terminfo database
    # The other options that you might consider looking at are XTerm/Rxvt
    # translations (and resources e.g. rxvt coming with cygwin has
    # Rxvt.backspacekey resource - by default set to ^?) and of course keymaps:
    # loadkeys/xkbcomp/xmodmap - whatever is applicable
    case $(infocmp | grep 'kbs=[^,]*') in
	*kbs=^H* | *kbs=\\b* )
	    if ! stty -a | grep -q 'erase = \^[Hh]'; then
		echo "Updating terminal settings to match terminfo database"
		stty erase ^H
	    fi
	    ;;
	*kbs=^?* | *kbs=\\177* )
	    if ! stty -a | grep -q 'erase = \^?'; then
		echo "Updating terminal settings to match terminfo database"
		stty erase ^?
	    fi
	    ;;
	* )
	    echo "Unknown setting for kbs capability.  Check it out and fix manually!"
	    ;;
    esac
    # Fix the terminfo database if it has Delete key missing
    if ! infocmp | grep -q 'kdch1='; then
	echo "Attempting to fix terminfo database for missing Delete key"
	tmpname_="$HOME/infocmp_tmp.$$"
	infocmp > $tmpname_
	# I guess this is the most widespread default
	echo -e '\tkdch1=\\E[3~,' >> $tmpname_
	# If $TERMINFO is non existent then tic fails (at least on solaris)
	# This variable should be set properly in bash_profile.
	if [ ! -e "$TERMINFO" ]; then
	    mkdir -p "$TERMINFO"
	fi
	tic $tmpname_
	rm $tmpname_
	unset tmpname_
    fi

    shopt -s extglob cmdhist	# extended globs and multiline commands as one entry
    shopt -u interactive_comments	# I never use comments in interactive
					# mode and I do sometimes need words
					# beginning with #

    export INPUTRC=~/.inputrc	# This should protect me from some damn admins
				# that sets this variable to non-existent file
				# or file that does not include user specific
				# inputrc

    # do not enter into the histry duplicate entries, ls, mutt, ...
    HISTIGNORE="&:ls:mutt:[bf]g:exit"
    HISTFILESIZE=1000

    # CDPATH=".:~:/usr"		# search path for the cd command

    # To decipher the setting below it probably would be helpful to know that \[
    # (\]) in the prompt are interpreted by bash as the beginning (end) of
    # a sequence of non-printing chars and the color description is
    # a composition of one or more of the following codes:
    # Attribute codes: 
    # 00=none 01=bold 04=underscore 05=blink 07=reverse 08=concealed
    # Color codes:
    # 0=black 1=red 2=green 3=yellow 4=blue 5=magenta 6=cyan 7=white
    # To get foreground/background color add 30/40
    #
    # Example: echo -e '\E[4;33;41m  FAILURE  \E[0m' will print an underlined
    # yellow text on a red background.
    #
    # Whether terminal supports given attribute or not is another issue :))
    #
    # Related to the above are XTerm.color0 to XTerm.color15 resources where you
    # can say what exactly you mean by e.g. bold/bright red -> XTerm.color9
    # (think in octal - bold being 010 :))

    # Somehow I like the default setting of cygwin (without the title bar part)
    # so I modified it a bit to suit my taste :)
    PS1='\[\033[32m\]\u@\[\033[1;32m\]\h\[\033[0;33m\] \w\[\033[0m\]\n$ '

    # New bash comes with: echo -ne "\033]0;${USER}@${HOSTNAME}: ${PWD}\007"
    # as a default value but I don't like this functionality and prefer
    # to set titlebar manually (see titlebar function below)
    unset PROMPT_COMMAND

    #
    # Functions and aliases (first the generic ones)
    #

    # Sets the title bar of the xterm/rxvt to the argument supplied
    titlebar () {
	if [ $# -lt 1 ]; then
	    echo "You have to give some name! Not changing anything :)"
	else
	    echo -ne "\033]0;$*\007"
	fi
    }

    alias p="${PAGER:=less}"	# use env var (and set it if empty)
    alias e="${EDITOR:=vim}"

    alias md=mkdir
    alias pd=pushd
    alias ungzip=gunzip			# I often make such mistake :))
    alias h='history 20'
    alias gdb='gdb -q'
    alias bc='bc -q'

    if type -t pinfo > /dev/null; then alias info=pinfo; fi
    if type -t mc > /dev/null; then alias mc='\mc -a -d -c'; fi

    basic_ls_="ls -F"
    if type -t dircolors > /dev/null; then
	if test -r "$HOME/.dir_colors"; then
	    eval $(dircolors -b "$HOME/.dir_colors")	# colorize output of ls
	elif test -r /etc/DIR_COLORS; then
	    eval $(dircolors -b /etc/DIR_COLORS)
	fi # if none available use the precompiled values
	basic_ls_="$basic_ls_ --color=tty"
    fi
    alias ls="$basic_ls_"
    alias ll="$basic_ls_ -l"
    alias la="$basic_ls_ -A"
    alias lla="$basic_ls_ -lA"
    # -h (human readable :)) option seems to be GNU ls extension but on newer
    # solaris it is also present so I leave it outside case below
    alias llh="$basic_ls_ -lh"

    case $OSTYPE in
	*linux*)	# Linux specific aliases
	    if [ -d /media/cdrom ]; then
		cd_dir_=/media/cdrom
	    else
		cd_dir_=/mnt/cdrom
	    fi
	    alias mcd="mount $cd_dir_"
	    alias ucd="umount $cd_dir_"
	    unset cd_dir_
	    # Switching codes for LAT1_MAP and USER_MAP from
	    # /usr/src/linux/Documentation/unicode.txt (in my case USER_MAP is
	    # iso8859-2 but I'm mainly using only polish diacritical characters)
	    alias plfont="echo -ne '\033(K'"
	    alias usfont="echo -ne '\033(B'"
	    # Well I often sit in the linux console so I've set up WindowMaker
	    # and aliases below to remind me that I have X session running
	    alias showX='if [ -e ~/.WMaker-running ]; then echo "Xsession running!"; fi'
	    alias w='\w; showX'
	    alias who='\who; showX'
	    ;;
	*cygwin*)
	    # This was useful when I used windows native vim.  Unfortunately
	    # I don't know a succinct way to make it foolproof to whitespace.
	    # If setting IFS to newline would split only on newline then the
	    # loop could be avoided but it is not :(
	    # e() {
	    #     local i=0; local -a fn
	    #     for f in "$@"; do
	    #         fn[i++]=$(cygpath -wa "$f")
	    #     done
	    #     $EDITOR "${fn[@]}"
	    # }
	    # On windows I sometimes don't start X server and use this alias
	    # to launch xterm with vim
	    alias E="rxvt -fn 10x20 -T VIM +sb -geometry 95x37 -e ${EDITOR:=vim}"
	    alias startx='\startx -- -fullscreen -clipboard -xkbrules xorg -xkbmodel pc104 -xkblayout pl -xkboptions "ctrl:nocaps" > ~/.xsession-errors 2>&1 &'
	    # another ones specific for windows :) - open the specified
	    # document/link/... in Windows registered application
	    alias cygrun="cygstart --showmaximized"
	    ;;
	*solaris*)
	    ;;
    esac
    unset basic_ls_

    # In bash 2 we have programmable completion :)) -- hip, hip, hooray!!!
    if [ -e ~/.bash_completion -a -e ~/.bash_completion.d ]; then
	export BASH_COMPLETION=$HOME/.bash_completion
	export BASH_COMPLETION_DIR=$HOME/.bash_completion.d
	. $BASH_COMPLETION
    fi

    if [ -r ~/.bash_local/bashrc ]; then	# Host specific settings
	. ~/.bash_local/bashrc
    fi
fi

# vim: set sw=4 tw=80:
