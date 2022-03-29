#!/bin/bash

linesdir=/misc/nyquist/lconcha/displasia_streamlines_dwi


for f in /misc/carr2/paulinav/Displasia_project/*/*/{30,60,120,150}/*_seg.nii.gz
do
  ff=$(basename $f)
  #echo $ff
  rat=$(echo $ff | awk -F_ '{print $1}')
  day=$(echo $ff | awk -F_ '{print $2}')
  grp=$(echo $ff | awk -F_ '{print $3}')
  echolor yellow  "[INFO] Rat: $rat    Day: $day    Group: $grp"
  testfile=$(ls ${linesdir}/${grp}/${rat}/${day}/*/*_smooth.tck | tail -n 1)
  if [ -z "$testfile" ]
  then
     echolor yellow "[INFO] Working on ${grp} ${rat} ${day}"
     mkdir -p ${linesdir}/${grp}/${rat}/${day}
     fsl_sub -N r${rat}-${day} nii2streams_brkraw_analysis.sh $f $f ${rat}-${day} ${linesdir}/${grp}/${rat}/${day}
   else
     echolor green "[INFO] Already processed, found:"
     echolor green "       $testfile"
     continue 
  fi
  
done
