#!/bin/bash
source `which my_do_cmd`

grp=$1
rat=$2
day=$3


dwidir=/misc/carr2/paulinav/Displasia_project/
corticalmaskdir=/misc/nyquist/lconcha/displasia_streamlines_dwi/corticalmasks

slicesfile=${dwidir}/${grp}/${rat}/${day}/${rat}_${day}.selected_slices
corticalmask=${corticalmaskdir}/${rat}_${day}_${grp}_corticalmask.nii.gz
ls $corticalmask


tmpDir=$(mktemp -d)

cat $slicesfile | tr ' ' '\n' | while read s
do
  echolor yellow " $s"
  dwi=${dwidir}/${grp}/${rat}/${day}/slice_${s}/${rat}_${day}_${grp}_hibval_deb.nii.gz
  ls $dwi
  mrmath -axis 3 $dwi mean - | mrcalc - 0 -gt $corticalmask -mul ${tmpDir}/slice_${s}_mask.nii
  echolor cyan "[INFO] Running mrds"
  my_do_cmd inb_mrds.sh \
    $dwi \
    ${dwi%.nii.gz}.{bvec,bval} \
    ${tmpDir}/slice_${s}_mask.nii \
    ${tmpDir}/slice_${s}_mrds

done


echolor green $tmpDir
ls $tmpDir
#rm -fR $tmpDir