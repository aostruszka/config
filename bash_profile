# .bash_profile
# Author: Andrzej M. Ostruszka

# User specific environment and startup programs.  There are two levels of
# configuration: system specific (that is the ones that should be valid on all
# hosts of given type) and host specific.  The first class is handled by case'es
# and the second by the .local/bash directory (if present).

shopt -s extglob        # I'm using extended patterns

case $OSTYPE in
  *cygwin*)
    # /cygdrive is too long for me so I use /win and try to remember current
    # setting in this var.
    export cygprefix=${${${(f)$(mount -p)}#*Flags }%% *}
    # Once upon the time I used windows native gvim so this setting was
    # needed in order to have it being able to load file
    #LESSEDIT='%E ?lm+%lm. $(cygpath -wa %f)'

    # I find it convenient to have Windows defined HOME which points to my home
    # directory but it is usually something of the sort d:\Profiles\XXX\Home so
    # instead I always make a XXX symlink in /home which point to the proper
    # direction and "correct" the HOME variable for those cygwin aware apps.
    if [[ -d /home/$(id -un) ]]; then
      HOME=/home/$(id -un)
    fi
    ;;
  *linux*)
    # These days it seems to be no problem but older distributions and/or
    # hosts over which I have no control can sometimes have the path screwed
    # up so below is a reasonable value to be used
    #if [[ $(id -un) == root ]]; then
    #  path=(/usr/local/sbin /usr/local/bin /sbin /bin
    #        /usr/sbin /usr/bin /usr/X11R6/bin)
    #else
    #  PATH=/usr/local/bin:/usr/bin:/bin:/usr/X11R6/bin
    #fi
    ;;
  *solaris*)
    # Programs in xpg4 are nicer (read more GNU like :)) so I prefer them.
    # But they still got pushed by GNU utils in my ~/bin and/or ~/localroot
    # directory if I happened to compile them.
    [[ -d /usr/xpg4/bin/ ]] && PATH=/usr/xpg4/bin:$PATH
    # Workarounds:
    # for -q option of grep just redirect the output to /dev/null
    # for -nu options of id this will do:
    #USERNAME=$(id | sed 's/.*uid=[0-9]*(\([^)]*\).*/\1/')
    ;;
esac

umask 022

# If ~/localroot exists then add ~/localroot/{bin,usr/bin} to PATH
if [[ -d $HOME/localroot ]]; then
  for f in $HOME/localroot/{usr/,}bin; do
    [[ -d $f ]] && PATH=$f:$PATH
  done
fi
unset f

# If ~/bin exist then prepend it to the PATH
[[ -d $HOME/bin ]] && PATH=$HOME/bin:$PATH

if [[ -d $HOME/tmp ]]; then
    TMP=$HOME/tmp
    TEMP=$TMP
else
    TMP=/tmp
    TEMP=$TMP
fi
export TMP TEMP

# I noticed sometimes that SHELL variable exists but is not exported so I make
# sure it is (IIRC this happens to me when the default shell is tcsh and I'm
# switching right away to bash in .tcshrc - don't ask me why I can't change the
# default shell :))
[[ -n $SHELL ]] && declare -x SHELL

# Usually programs which require VISUAL fall back to EDITOR if it's
# missing so I keep only one variable - with more intuitive name :)
unset VISUAL
export EDITOR=vim

BASH_ENV="$HOME/.bashrc"
USERNAME=$(id -nu)
PAGER=less
LESS=SR # I prefer to see lines not wrapped.  This also protects me from some
	# admin that sets this variable (once it happened that he/she had set it
	# to include x2 - one of the easiest ways to make me upset is to not
	# treat tab as 8 spaces :)).  'R' makes displaying of color sequences.

# PAGER variable takes precedence over default pager setting for man but I have
# it set without -r (so that viewing binary files won't mess with my terminal)
# which messes "coloring" in man so I correct it here.  This is nearly default
# man setting - without case insensitive search.
MANPAGER='less -sr'

export BASH_ENV USERNAME PAGER MANPAGER LESS

# There's no need for setting these on linux and cygwin but it's
# harmless (I somehow need to do this on solaris cause it doesn't
# fallback to ~/.terminfo)
export TERMINFO=$HOME/.terminfo

# Set those below only if they are not empty (Note: export by itself prints the
# exported variables)
#export ${MANPATH:+MANPATH} ${INFOPATH:+INFOPATH}

# These three seems to be GNU specific but I guess they are harmless for nonGNU
MANPL=60	# man pages length
VERSION_CONTROL=numbered	# For -b option of cp, mv etc. to always make
				# "numbered backups"
TIMEFMT="real: %E, user:%U, sys:%S, CPU:%P" # format of timings

export MANPL VERSION_CONTROL TIMEFMT

# Now is a section regarding setting of a valid locale support.  As you can
# see below I'm only using LC_CTYPE & LC_COLLATE as I prefer to interface with
# the computer in english :) but I still would like to use polish chars
# properly.  Users who don't speak polish should amend this part accordingly :))
#
# Unfortunatelly the locale names are not standarized.  It should be something
# of the form: language_territory.codeset (e.g. pl_PL.utf8) but on some systems
# (solaris) it does not work so this is kind of workaround :) - I omit the
# codeset below cause I think it is retrieved from the locale itself (it would
# matter for me if there were more then one acceptable value for 'pl' :))

# Use the cached value (if it exists)

# This supposed to protect me from the situation when one disk is seen as home
# on two hosts that have different support for locale (it happened to me twice
# :)).  The format is simple:
# hostname:export LC_CTYPE=XX LC_COLLATE=XX

host_=${HOSTNAME:-$(hostname)}
value_=$(grep $host_ $HOME/.valid_locale 2> /dev/null)

if [[ $? == 0 ]]; then # if success
  eval ${value_#*:}
else
  if type -p locale > /dev/null; then # if we got 'locale' executable
    locale_=$(locale -a | grep -i '^pl' | head -1)
  elif type -p perl > /dev/null; then	# if perl in path
    locale_=$(perl <<-'LOCALE_TEST_'
	use POSIX qw(locale_h);
	for my $l (("polish", "pl_PL", "pl")) {
	    if (setlocale(LC_CTYPE, $l) && setlocale(LC_COLLATE, $l)) {
	        print $l;
	        exit 0;
	    }
	}
	LOCALE_TEST_
    )
  else
    for f in /usr/share/locale /usr/lib/locale; do
      if [[ -d $f ]]; then
	locale_=$(ls -d $f/pl* 2>/dev/null | head -1)
	if [[ -n $locale_ ]]; then
	  locale_=$(basename $locale_)
	  break;
	fi
      fi
    done
  fi
  if [[ -n $locale_ ]]; then
      export LC_CTYPE=$locale_ LC_COLLATE=$locale_ POLISH_LOCALE=1
      echo "${host_}:export LC_CTYPE=$locale_ LC_COLLATE=$locale_ POLISH_LOCALE=1" >> "$HOME/.valid_locale"
  else
      export LC_CTYPE=C LC_COLLATE=C
      echo "${host_}:export LC_CTYPE=C LC_COLLATE=C" >> "$HOME/.valid_locale"
  fi
  unset locale_
fi
unset host_ value_

# Source any local (host specific) settings
if [ -r "$HOME/.local/bash/bash_profile" ]; then
    . "$HOME/.local/bash/bash_profile"
fi

# If load_user_profile_ is set then this means that we are being sourced for the
# env vars only and we should not source the bashrc (e.g. .xinitrc/.xsession or
# the shell has been started without --login to omit invalid/harmful system
# /etc/profile etc. but the user profile should be loaded).

if [ ! "$load_user_profile_" -a -r "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# vim: set sw=4 tw=80:
