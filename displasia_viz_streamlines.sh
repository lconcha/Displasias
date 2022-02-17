#!/bin/bash
source `which my_do_cmd`

help(){
  echo "

How to use:
  `basename $0` <resultsfolder>

resultsfolder is the output folder for nii2streams_T2analysis.sh

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



outfolder=$1


t2=${outfolder}/*_t2.nii.gz
lines=${outfolder}/lines.nii.gz


streamlines=""
for f in ${outfolder}/??/tck/*resampled.tck
do
  n=`tckinfo -count $f |  grep count: | head -n 1 | awk -F: '{print $2}' | sed 's/ //g'`
  #echolor yellow "$f has $n streamlines"
  f_linenums=${f%.tck}_linenumbers.txt
  seq 1 $n > $f_linenums
  f_linelengths=${f%.tck}_linelengths.txt
  tckstats -quiet -force -dump $f_linelengths $f
  streamlines="${streamlines} -tractography.load $f -tractography.tsf_load $f_linenums -tractography.tsf_load $f_linelengths"
done

my_do_cmd  mrview $t2 \
  -interpolation false \
  -mode 2 \
  -roi.load $lines \
  $streamlines