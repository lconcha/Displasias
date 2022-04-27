#!/bin/bash



imagesdir=/misc/carr2/paulinav/Displasia_project
logsdir=${imagesdir}/logs

for grp in CTRL BCNU
do
  for dr in ${imagesdir}/${grp}/*
  do
    rat=$(basename $dr)
    for dd in ${imagesdir}/${grp}/${rat}/*
    do
      day=$(basename $dd)
      echolor cyan "[INFO] Submitting job for $grp $rat $day"
      fsl_sub -N mrds_${rat}${day} -l $logsdir -s smp,3 displasia_mrds.sh $grp $rat $day
    done
  done
done
