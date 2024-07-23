# Use ( | # ## and other goodies for globbing in all shels
set -o extended_glob
# This reduces the need for quoting to handle possible white space
# inside parameters.  You can always force it with ${=PARAM} like:
#$ f="a b"                                
#$ for l in $f; do echo $l; done
#a b
#$ for l in ${=f}; do echo $l; done
#a
#b
set -o no_sh_word_split

if [ -r ~/.local/zsh/zshenv ]; then # Host specific settings
  . ~/.local/zsh/zshenv
fi

# This will try to source every .zshenv in path between $HOME and $PWD
# so that you can place .zshenv in some project directory and have it
# automatically sourced when starting new shell in its subtree
if [[ $PWD == $HOME/* ]]; then
  o_=$HOME
  for d_ in $(echo ${PWD#$o_} | tr '/' ' '); do
    o_+=/$d_
    if [ -r $o_/.zshenv ]; then . $o_/.zshenv; fi
  done
  unset o_ d_
fi
