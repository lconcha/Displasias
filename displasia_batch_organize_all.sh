#!/bin/bash
source `which my_do_cmd`
fakeflag=""


organizeddir=/misc/nyquist/lconcha/displasia
errorlog=displasia_organize_all_errorlog.txt


imagesdir=/misc/carr2/paulinav/Displasia_project
dwistreamlinesdir=/misc/nyquist/lconcha/displasia_streamlines_dwi
corticalmasksdir=/misc/nyquist/lconcha/displasia_streamlines_dwi/corticalmasks
preprocdir=/misc/nyquist/lconcha/paulinav_preproc/preproc

errorlog=displasia_move_files_errorlog.txt
if [ -f $errorlog ]; then rm $errorlog;fi

checkandcopy(){
  forig=$1
  fdest=$2
  if [ ! -f $forig ]
  then
     echolor red "[ERROR] Not found: $forig"
     echo $forig >> $errorlog
  else
     ddest=$(dirname $fdest)
     if [ ! -d $ddest ]
     then
        my_do_cmd $fakeflag mkdir -p $ddest
     fi
     if [ -f $fdest ]
     then
        echolor green "[INFO] File exists: $fdest"
     else
       my_do_cmd $fakeflag cp $forig $fdest
     fi
  fi  
}


for grp in CTRL BCNU
do
  for dr in ${imagesdir}/${grp}/*
  do
    rat=$(basename $dr)
    for dd in ${imagesdir}/${grp}/${rat}/*
    do
      day=$(basename $dd)
      destfold=${organizeddir}/${grp}/${rat}/${day}
      # raw files
      T2_regrid=${imagesdir}/${grp}/${rat}/${day}/${rat}_${day}_${grp}_T2_regrid.nii.gz
      checkandcopy $T2_regrid \
                   ${destfold}/anat/T2_regrid.nii.gz
      T2_lines=${imagesdir}/${grp}/${rat}/${day}/${rat}_${day}_${grp}_T2.nii.gz
      checkandcopy $T2_lines \
                   ${destfold}/anat/lines.nii.gz
      dwi_hibval_deb=${imagesdir}/${grp}/${rat}/${day}/${rat}_${day}_${grp}_hibval_deb.nii.gz
      checkandcopy $dwi_hibval_deb \
                   ${destfold}/dwi/dwi_hibval_deb.nii.gz
      checkandcopy ${dwi_hibval_deb%.nii.gz}.bvec \
                   ${destfold}/dwi/dwi_hibval_deb.bvec
      checkandcopy ${dwi_hibval_deb%.nii.gz}.bval \
                   ${destfold}/dwi/dwi_hibval_deb.bval
      dwi_lines=${imagesdir}/${grp}/${rat}/${day}/${rat}_${day}_${grp}_seg.nii.gz
      checkandcopy $dwi_lines \
                   ${destfold}/dwi/lines.nii.gz
      txteddyoutlierss=${preprocdir}/${rat}_${day}_${grp}_hibval_de.qc/${rat}_${day}_${grp}_hibval_de.eddy_outlier_map
      checkandcopy $txteddyoutlierss \
                   ${destfold}/derivatives/dwi/eddy_outlier_map
      txtselectedslices=${imagesdir}/${grp}/${rat}/${day}/${rat}_${day}.selected_slices
      checkandcopy $txtselectedslices \
                   ${destfold}/derivatives/dwi/selected_slices
             


    done
  done
done