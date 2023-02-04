#!/bin/bash

# this is just a wrapper for the matlab function



Inputs=""
while getopts "t:d:n:i:p:" flag
do
    case "${flag}" in
        t) tck=${OPTARG};;
        d) PDD=${OPTARG};;
        n) nComp=${OPTARG};;
        i) input=${OPTARG};Inputs="$Inputs '$input'";;
        p) prefix=${OPTARG};;
    esac
done

mInputs=`echo $Inputs | sed 's/ /,/g'`

matlabjobfile=/tmp/matlabjobfile.m

echo "
addpath('/home/lconcha/software/mrtrix_matlab/matlab');
addpath('/home/lconcha/software/Displasias/');

  f_tck     = '$tck';
  f_PDD     = '$PDD';
  f_ncomp   = '$nComp';
  ff_values = {$mInputs};
  f_prefix  = '$prefix';
  
  
VALUES = displasia_tckfixelsample(f_tck, f_PDD, f_ncomp, ff_values, f_prefix);
exit
" > $matlabjobfile

cat $matlabjobfile

matlab -nodisplay -nosplash -nojvm <$matlabjobfile

rm $matlabjobfile

