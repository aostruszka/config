# .bash_profile
# Author: Andrzej M. Ostruszka
# $Id: bash_profile 36 2006-06-23 10:30:25Z aao014 $

# User specific environment and startup programs.  There are two levels of
# configuration: system specific (that is the ones that should be valid on all
# hosts of given type) and host specific.  The first class is handled by case'es
# and the second by the .bash_local directory (if present).

umask 027
shopt -s extglob        # I'm using extended patterns

case $OSTYPE in
  *cygwin*)
	export LESSCHARSET=iso8859
	# Once upon the time I used windows native gvim so this setting was
	# needed in order to have it being able to load file
	#LESSEDIT='%E ?lm+%lm. $(cygpath -wa %f)'
	test -d "$HOME/CVS" && export CVSROOT="$HOME/CVS"
	test -d "$HOME/SVN" && export SVNREPO="file://$HOME/SVN"
	;;
  *linux*)
	# Sometimes the path is screwed up on linux :) so I set
	# a reasonable value by myself
	PATH="/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin"
	test -d "$HOME/CVS" && export CVSROOT="$HOME/CVS"
	test -d "$HOME/SVN" && export SVNREPO="file://$HOME/SVN"
	;;
  *solaris*)
	# Programs in xpg4 are nicer (read more GNU like :)) so I prefer them.
	# But they still got pushed by GNU utils in my ~/?(localroot/)bin
	# directory if I happened to compile them.
	if [ -d /usr/xpg4/bin/ ]; then
	    PATH="/usr/xpg4/bin:$PATH"
	fi
	# Workarounds:
	# for -q option of grep just redirect the output to /dev/null
	# for -nu options of id this will do:
	#USERNAME=$(id | sed 's/.*uid=[0-9]*(\([^)]*\).*/\1/')
	;;
esac

# If ~/bin exist then prepend it to the PATH
test -d "$HOME/bin" && PATH="$HOME/bin:$PATH"

if [ -d "$HOME/tmp" ]; then
    TMP="$HOME/tmp"
    TEMP=$TMP
else
    TMP=/tmp
    TEMP=$TMP
fi

# I noticed sometimes that SHELL variable exists but is not exported so I make
# sure it is (IIRC this happens to me when the default shell is tcsh and I'm
# switching right away to bash in .tcshrc - don't ask me why I can't change the
# default shell :))
[ -n $SHELL ] && declare -x SHELL

# Usually programs which require VISUAL fall back to EDITOR if it's
# missing so I keep only one variable - with more intuitive name :)
unset VISUAL
EDITOR=vim

BASH_ENV="$HOME/.bashrc"
USERNAME=$(id -nu)
PAGER=less
LESS=S	# I prefer to see lines not wrapped.  This also protects me from some
	# admin that sets this variable (ones it happened that he/she had set it
	# to include x2 - one of the easiest ways to make me upset is to not
	# treat tab as 8 spaces :))

export EDITOR BASH_ENV USERNAME PAGER LESS TMP TEMP

# There's no need for setting these on linux and cygwin but it's
# harmless (I somehow need to do this on solaris cause it doesn't
# fallback to ~/.terminfo)
export TERMINFO="$HOME/.terminfo"

# Set those below only if they are not empty (Note: export by itself prints the
# exported variables)
#export ${MANPATH:+MANPATH} ${INFOPATH:+INFOPATH}

# These three seems to be GNU specific but I guess they are harmless for nonGNU
MANPL=60	# man pages length
VERSION_CONTROL=numbered	# For -b option of cp, mv etc. to always make
				# "numbered backups"
TIME="real: %e(%E), user:%U, sys:%S, CPU:%P" # format of timings

export MANPL VERSION_CONTROL TIME

# Unfortunatelly the locale names are not standarized.  It should be something
# of the form: language_territory.codeset (e.g. pl_PL.iso8859-2) but on some
# systems (solaris) it does not work so this is kind of workaround :) - I omit
# the codeset below cause I think it is retrieved from the locale itself (it
# would matter if there were more then one acceptable value for 'pl')

# Use the cached value (if it exists)

# This supposed to protect me from the situation when one disk is seen as home
# on two hosts that have different support for locale.  The format is simple:
# hostname:export LC_CTYPE=XX LC_COLLATE=XX

host_=${HOSTNAME:-$(hostname)}
value_=$(grep $host_ "$HOME/.valid_locale" 2> /dev/null)

if [ $? == 0 ]; then # if success
    eval ${value_#*:}
else
    if type -t perl > /dev/null; then	# if perl in path
	locale_=$(perl <<-'LOCALE_TEST_'
		use POSIX qw(locale_h);
		for my $l (("polish", "pl_PL", "pl", "C")) {
		  if (setlocale(LC_CTYPE, $l) && setlocale(LC_COLLATE, $l)) {
		    print $l;
		    exit 0;
		  }
		}
		LOCALE_TEST_
		)
    elif type -p locale > /dev/null; then # if we got 'locale' executable
	locale_=$(locale -a | grep ^pl | head -1)
    else
	for f in /usr/share/locale /usr/lib/locale; do
	    if [ -r "$f" ]; then
		locale_=$(basename $(ls -d "$f"/pl* 2>/dev/null | head -1))
		if [ -n $locale_ ]; then break; fi
	    fi
	done
    fi
    if [ -n $locale_ ]; then
	export LC_CTYPE=$locale_ LC_COLLATE=$locale_
	echo "$host_:export LC_CTYPE=$locale_ LC_COLLATE=$locale_" >> "$HOME/.valid_locale"
    else
	echo 'Something is screwed up with locale database! Even "C" does not work!'
    fi
    unset locale_
fi
unset host_ value_

# Source any local (host specific) settings
if [ -r "$HOME/.bash_local/bash_profile" ]; then
    . "$HOME/.bash_local/bash_profile"
fi

# If load_user_profile_ is set then this means that we are being sourced for the
# env vars only and we should not source the bashrc (e.g. .xinitrc/.xsession or
# the shell has been started without --login to omit invalid/harmful system
# /etc/profile etc. but the user profile should be loaded).

if [ ! "$load_user_profile_" -a -r "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# vim: set sw=4 tw=80:
