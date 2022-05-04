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
      my_do_cmd $fakeflag displasia_anat_streamline_lengths.sh $grp $rat $day
    done
  done
done