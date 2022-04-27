#!/bin/bash
source `which my_do_cmd`
fakeflag=""

grp=$1
rat=$2
day=$3


imagesdir=/misc/nyquist/lconcha/displasia


for s in l r
do
    for tck in  ${imagesdir}/${grp}/${rat}/${day}/derivatives/anat/*/tck/anat_${s}_out_resampled_native.tck
    do
      #echolor yellow "[INFO] Getting length for $tck"
      my_do_cmd $fakeflag tckstats -dump ${tck%.tck}_length.txt $tck
    done
done