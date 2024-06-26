#!/bin/bash
source `which my_do_cmd`
fakeflag=""

grp=$1
rat=$2
day=$3

imagesdir=/misc/nyquist/lconcha/displasia


corticalmask=${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/corticalmask.nii.gz 

if [ -f $corticalmask ]
then
  echolor green "[INFO] Cortical mask exists: $corticalmask"
  echolor green "       Not overwritting. Bye."
  exit 0
fi


tmpDir=$(mktemp -d)


dwis=${imagesdir}/${grp}/${rat}/${day}/dwi/dwi_hibval_deb
mincRGB=${imagesdir}/${grp}/${rat}/${day}/derivatives/dwi/??/dwi_?_minc_thick_RGB.nii.gz


isOK=1
for f in ${dwis}.{bval,bvec,nii.gz} $mincRGB
do
  if [ ! -f $f ]
  then
    echolor red "[ERROR] Cannot find $f"
    isOK=0
  fi
done

if [ $isOK -eq 0 ]
then
  exit 2
fi


my_do_cmd $fakeflag dwi2mask \
  -fslgrad ${dwis}.{bvec,bval,nii.gz} \
  ${tmpDir}/mask.nii
my_do_cmd $fakeflag dwi2tensor \
  -mask ${tmpDir}/mask.nii \
  -fslgrad ${dwis}.{bvec,bval,nii.gz} \
  ${tmpDir}/dt.nii
my_do_cmd $fakeflag tensor2metric -fa ${tmpDir}/fa.nii ${tmpDir}/dt.nii


my_do_cmd $fakeflag mrcat -axis 3 \
  $mincRGB \
  ${tmpDir}/rgb.nii
  

my_do_cmd $fakeflag mrcalc ${tmpDir}/rgb.nii -abs ${tmpDir}/rgb_abs.nii
my_do_cmd $fakeflag mrmath -axis 3 ${tmpDir}/rgb_abs.nii sum ${tmpDir}/rgb_sum.nii

my_do_cmd $fakeflag nii2streams_toOriginalOrientation.sh \
  ${tmpDir}/rgb_sum.nii \
  ${tmpDir}/fa.nii \
  ${tmpDir}/rgb_oriented.nii

my_do_cmd $fakeflag mrcalc \
  ${tmpDir}/rgb_oriented.nii \
  0 -gt \
  ${tmpDir}/rgb_oriented_bin.nii

my_do_cmd $fakeflag mrcalc \
  ${tmpDir}/mask.nii \
  ${tmpDir}/rgb_oriented_bin.nii \
  -mul \
  ${tmpDir}/rgb_oriented_bin_masked.nii

my_do_cmd $fakeflag maskfilter \
  -npass 2 \
  ${tmpDir}/rgb_oriented_bin_masked.nii \
  dilate \
  ${tmpDir}/rgb_oriented_bin_masked_dil.nii

my_do_cmd $fakeflag mrconvert \
  ${tmpDir}/rgb_oriented_bin_masked_dil.nii \
  $corticalmask

rm -fR $tmpDir