#!/bin/bash
source `which my_do_cmd`

help(){
  echo "

How to use:
  `basename $0` [options] <resultsfolder>

resultsfolder is the output folder for nii2streams_T2analysis.sh

Options:

-n    Show results in native (brkraw) space.
-p    Show results in permuted space.




LU15 (0N(H4
INB UNAM
Feb 2022
lconcha@unam.mx
  "
}


if [ $# -lt 1 ]
then
  echolor red "Not enough arguments"
	help
  exit 2
fi



doNative=0
doPermuted=0
while getopts np flag
do
    case "${flag}" in
        n) doNative=1;shift;;
        p) doPermuted=1;shift;;
    esac
done


if [ $doNative -eq 0 -a $doPermuted -eq 0 ]
then
  echolor red "Need to specify  -p (permuted) or/and -n (native)"
  exit 2
fi

outfolder=$1


image=${outfolder}/*image*.nii.gz
lines=${outfolder}/lines.nii.gz


streamlines=""

if [ $doPermuted -eq 1 ]
then
  for f in ${outfolder}/??/tck/*resampled.tck
  do
    n=`tckinfo -count $f |  grep count: | head -n 1 | awk -F: '{print $2}' | sed 's/ //g'`
    #echolor yellow "$f has $n streamlines"
    f_linenums=${f%.tck}_linenumbers.txt
    seq 1 $n > $f_linenums
    f_linelengths=${f%.tck}_linelengths.txt
    tckstats -quiet -force -dump $f_linelengths $f
    streamlines="${streamlines} -tractography.load $f -tractography.tsf_load $f_linenums"
  done
  for f in ${outfolder}/??/tck/*seeds*_resampled_imagespace.tck
  do
    streamlines="${streamlines} -tractography.load $f \
                -tractography.geometry points"
                #-tractography.tsf_load $f_linenums"
  done
fi


if [ $doNative -eq 1 ]
then
  for f in ${outfolder}/??/tck/*native.tck
  do
    streamlines="${streamlines} -tractography.load $f -tractography.geometry points"
  done
fi



images=""
images=""
if [ $doPermuted -eq 1 ]
then
  imtolodad=`ls ${outfolder}/*image.nii.gz`
  images="$images $imtolodad"
fi

if [ $doNative -eq 1 ]
then
  imtolodad=`ls ${outfolder}/*image_native.nii.gz`
  images="$images $imtolodad"
fi

my_do_cmd  mrview $images \
  -interpolation false \
  -mode 2 \
  -roi.load $lines \
  $streamlines