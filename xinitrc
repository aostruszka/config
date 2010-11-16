cd $HOME
if [ -d ~/.fonts ]; then
  xset +fp $HOME/.fonts
fi
xrdb -DPOLISH_LOCALE=${POLISH_LOCALE:-0} -merge $HOME/.Xdefaults
exec wmaker
