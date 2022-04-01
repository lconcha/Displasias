#!/bin/bash
source `which my_do_cmd`
fakeflag=""

imagesdir=/misc/nyquist/lconcha/displasia
for grp in CTRL BCNU
do
  for dr in ${imagesdir}/${grp}/*
  do
    rat=$(basename $dr)
    for dd in ${imagesdir}/${grp}/${rat}/*
    do
      day=$(basename $dd)
      echolor yellow "[INFO] Working on $grp $rat $day"
      testfile=$(ls ${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/slice_??/dwi.nii.gz 2>/dev/null | tail -n 1)
      if [ ! -z "$testfile"  ]
      then
        if [ -f $testfile ]
        then
            echolor green "[INFO] DWI already separated into slices. Found $testfile"
            sleep 1
        fi
      else
        my_do_cmd $fakeflag displasia_separate_slices_removing_outliers.sh \
            ${imagesdir}/${grp}/${rat}/${day}
      fi
    done
  done
done