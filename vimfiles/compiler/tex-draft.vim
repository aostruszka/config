compiler tex
setlocal efm-=\%+WLaTeX\ %.%#Warning:\ %.%#line\ %l%.%#
setlocal efm-=\%+W%.%#\ at\ lines\ %l--%*\\d
setlocal efm-=\%WLaTeX\ %.%#Warning:\ %m
setlocal mp=make
