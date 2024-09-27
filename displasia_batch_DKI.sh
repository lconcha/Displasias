#!/bin/bash



imagesdir=/misc/carr2/paulinav/Displasia_project/displasia
logsdir=/misc/carr2/paulinav/Displasia_project/logs
fails=${logsdir}/failed_DKI.txt
if [ -f $fails ]; then rm $fails;fi




for grp in CTRL BCNU
do
  for dr in ${imagesdir}/${grp}/*
  do
    rat=$(basename $dr)
    for dd in ${imagesdir}/${grp}/${rat}/*
    do
      day=$(basename $dd)
      dwi=${imagesdir}/${grp}/${rat}/${day}/${rat}_${day}_${grp}_hibval_deb.nii.gz
      bval=${dwi%.nii.gz}.bval
      bvec=${dwi%.nii.gz}.bvec
      mask=${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/${rat}_${day}_${grp}_DTInolin_FA.nii.gz
      outdir=${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/dki
      if [ ! -f $dwi ]; then echo $dwi >> $fails;fi
      #fsl_sub -N dki_${rat}${day} -l $logsdir -s smp,6 \
        displasia_run_DKI.sh $dwi $bval $bvec $mask $outdir
    done
  done
done

