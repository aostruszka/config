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
