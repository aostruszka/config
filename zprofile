# .zprofile
# Author: Andrzej M. Ostruszka

# User specific environment and startup programs.  There are two levels of
# configuration: system specific (that is the ones that should be valid on all
# hosts of given type) and host specific.  The first class is handled by case'es
# and the second by the .zsh/local directory (if present).

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
    ;;
esac

#if [[ $(id -un) == root ]]; then
#  # Most of time (as a root) I want to make user visible files
#  umask 022
#else
#  umask 027
#fi
umask 022

# If ~/localroot exists then add ~/localroot/{bin,usr/bin} to PATH
if [[ -d $HOME/localroot ]]; then
  for f in $HOME/localroot/{usr/,}bin; do
    [[ -d $f ]] && PATH=$f:$PATH
  done
fi
unset f

# Check for cargo path
if [[ -n $CARGOPATH ]]; then
    PATH=$CARGOPATH:$PATH
elif [[ -d $HOME/.cargo/bin ]]; then
    PATH=$HOME/.cargo/bin:$PATH
fi

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
# switching right away to bash/zsh in .tcshrc - don't ask me why I can't change
# the default shell :))
[[ -n $SHELL ]] && declare -x SHELL

# Usually programs which require VISUAL fall back to EDITOR if it's
# missing so I keep only one variable - with more intuitive name :)
unset VISUAL
if whence -p nvim > /dev/null; then
    EDITOR=nvim
else
    EDITOR=vim
fi
export EDITOR

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

export PAGER MANPAGER LESS

# There's no need for setting these on linux and cygwin but it's
# harmless (I somehow need to do this on solaris cause it doesn't
# fallback to ~/.terminfo)
export TERMINFO=$HOME/.terminfo

# Add local man/info dirs if present
if [[ -d ~/.local/share/man ]]; then
    export  MANPATH=~/.local/share/man:${MANPATH:-$(man --path)}
fi
# In case of info we don't have to append defaults - they are always used
if [[ -d ~/.local/share/info ]]; then
    export INFOPATH=~/.local/share/info
fi

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
if [ -r ~/.local/zsh/zprofile ]; then
    . ~/.local/zsh/zprofile
fi

# Sanitize the path (remove duplicated entries)
typeset -U PATH

# vim: set sw=4 tw=80:
