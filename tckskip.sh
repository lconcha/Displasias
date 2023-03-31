#!/bin/bash

tckIN=$1
tckOUT=$2
skip=$3


ntracks=$(tckinfo -quiet -count $tckIN | grep " count:" | awk '{print $2}')

tmpDir=$(mktemp -d)

tckconvert $tckIN ${tmpDir}/track-[].txt

for n in $(seq -w 0000000 $skip $(( $ntracks -1 )) )
do
  cp $tmpDir/track-${n}.txt ${tmpDir}/keep-${n}.txt
done


tckconvert ${tmpDir}/keep-[].txt $tckOUT
  
rm -fR $tmpDir
