#!/bin/bash
source `which my_do_cmd`
fakeflag=""

echo ----------------------------
date
echo $0 $@
echo ----------------------------

grp=$1
rat=$2
day=$3

imagesdir=/misc/carr2/paulinav/Displasia_project

im_orig=${imagesdir}/${grp}/${rat}/${day}/${rat}_${day}_${grp}_T2_regrid.nii.gz

export MINC_FORCE_V2=0
export PATH=/home/inb/lconcha/fmrilab_software/minc/bin:${PATH}


if [ ! -f $im_orig ]
then
  echolor red "[ERROR] Cannot find $im_orig"
  exit 2
else
  echolor yellow "[INFO] Found $im_orig"
fi


tmpDir=$(mktemp -d)


if (file $im_orig | grep -q compressed ) ; then
     echolor yellow "[INFO] Original file is compressed. Unzipping to ${tmpDir}/im_orig.nii"
     gunzip -c $im_orig > ${tmpDir}/im_orig.nii
     im_orig=${tmpDir}/im_orig.nii

fi

outdir=${imagesdir}/${grp}/${rat}/${day}/derivatives/anat
if [ ! -d $outdir ]
then
  mkdir -p $outdir
fi


echolor cyan "[INFO] Performing pre-processing."
my_do_cmd $fakeflag inb_rat_preproc_anat.sh \
  -i $im_orig \
  -o ${outdir}/${rat}_${day}_${grp}_preproc \
  -d /misc/mansfield/lconcha/exp/ratAtlas/fischer344/Fischer344_nii_v4


im_preproc=${outdir}/${rat}_${day}_${grp}_preproc_biascorrected_denoised.nii

echolor cyan "[INFO] Performing registration to atlas, masking, and further bias field correction"
my_do_cmd $fakeflag inb_rat_anat2atlas.sh \
  -n \
  -i $im_preproc \
  -o ${outdir}/${rat}_${day}_${grp}_reg \
  -d /misc/mansfield/lconcha/exp/ratAtlas/fischer344/Fischer344_nii_v4 \


mv ${outdir}/${rat}_${day}_${grp}_reg_native_nlin_biascorrected.nii.gz ${tmpDir}/native.nii.gz
refstrides=$(mrinfo -strides $im_orig | tr ' ' ',')
my_do_cmd mrconvert \
  -strides $refstrides \
  ${tmpDir}/native.nii.gz \
  ${tmpDir}/native_strides.nii.gz
my_do_cmd fslcpgeom $im_orig ${tmpDir}/native_strides.nii.gz
my_do_cmd mrconvert \
  ${tmpDir}/native_strides.nii.gz \
  ${outdir}/${rat}_${day}_${grp}_reg_native_nlin_biascorrected.nii.gz

ls  $tmpDir/*

rm -fR $tmpDir
date
