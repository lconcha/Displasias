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
      echolor cyan "[INFO] Working on $grp $rat $day"

      echolor yellow "[INFO] Streamlines on T2 space"
      testfile=$(ls ${imagesdir}/${grp}/${rat}/${day}/derivatives/anat/??/tck/anat_?_seeds_smooth_resampled_imagespace_native.tck 2>/dev/null | tail -n 1)
      if [ ! -z "$testfile" -a -f $testfile ]
      then
        echolor green "[INFO]   Anat Streamlines already exist. Found $testfile"
      else
        echolor yellow "[INFO]   Running streamlines on T2 space"
        lines=${imagesdir}/${grp}/${rat}/${day}/anat/lines.nii.gz
        t2=${imagesdir}/${grp}/${rat}/${day}/anat/T2_regrid.nii.gz
        outfolder=${imagesdir}/${grp}/${rat}/${day}/derivatives/anat
        mkdir -p $outfolder
        my_do_cmd $fakeflag  fsl_sub -N anat_${rat}-${day} \
            -l /misc/nyquist/lconcha/logs \
            -s smp,4 \
            nii2streams_brkraw_analysis.sh \
            $lines \
            $t2 \
            $outfolder \
            anat
     fi


      echolor yellow "[INFO] Streamlines on DWI space"
      testfile=$(ls ${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/??/tck/dwi_?_seeds_smooth_resampled_imagespace_native.tck 2>/dev/null | tail -n 1)
      if [ ! -z "$testfile" -a -f $testfile ]
      then
        echolor green "[INFO]   DWI Streamlines already exist. Found $testfile"
      else
        echolor yellow "[INFO]   Running streamlines on DWI space"
        lines=${imagesdir}/${grp}/${rat}/${day}/dwi/lines.nii.gz
        dwi=${imagesdir}/${grp}/${rat}/${day}/dwi/dwi_hibval_deb.nii.gz
        outfolder=${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi
        mkdir -p $outfolder
        my_do_cmd $fakeflag fsl_sub -N anat_${rat}-${day} \
            -l /misc/nyquist/lconcha/logs \
            -s smp,4 \
            nii2streams_brkraw_analysis.sh \
            $lines \
            $lines \
            $outfolder \
            dwi
     fi

    done
  done
done
