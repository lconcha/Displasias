#!/bin/bash
source `which my_do_cmd`

d=/misc/nyquist/paulinav/MAESTRIA/DWI_paulinav

grp=$1
day=$2
rat=$3
outbase=$4


tmpDir=$(mktemp -d)

dwi_deb=${d}/${grp}/${day}/${rat}/dwi/dwi_hibval_deb.nii.gz
bval=${dwi_deb%.nii.gz}.bval
bvec=${dwi_deb%.nii.gz}.bvec

my_do_cmd mrconvert \
  -fslgrad $bvec $bval \
  $dwi_deb \
  ${tmpDir}/dwi_deb.mif

my_do_cmd dwiextract \
  -bzero \
  ${tmpDir}/dwi_deb.mif \
  ${tmpDir}/b0s.mif

my_do_cmd mrmath \
  -axis 3 \
  ${tmpDir}/b0s.mif \
  mean \
  ${tmpDir}/av_b0.mif



# Collect all cortical streamlines and create a mask
my_do_cmd tckedit \
  ${d}/${grp}/${day}/${rat}/*/tck/dwi_?_out_resampled_native.tck \
  ${tmpDir}/cortical_streamlines.tck

my_do_cmd tckmap \
  -template ${tmpDir}/av_b0.mif \
  ${tmpDir}/cortical_streamlines.tck \
  ${tmpDir}/cortical_mask.mif


# Get the median value for the cortex
the_median=$(mrstats \
  -mask ${tmpDir}/cortical_mask.mif \
  -output median \
  ${tmpDir}/av_b0.mif)

echolor cyan "The median is $the_median"


my_do_cmd mrcalc \
  ${tmpDir}/dwi_deb.mif \
  $the_median \
  -div \
  ${outbase}_debs.mif

echo mrview $dwi_deb ${outbase}_debs.mif

rm -fR $tmpDir