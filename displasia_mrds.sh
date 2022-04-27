#!/bin/bash
source `which my_do_cmd`



imagesdir=/misc/nyquist/lconcha/displasia
dwi_folder=$imagesdir



help(){
  echo "


Fit multi-tensors using multi-resolution discrete search (MRDS) within a mask.

-------------------
NOTE:
This script is designed to work on a slice-by-slice fashion, within a pre-defined
folder structure that separates each slice and eliminates signal outliers.
-------------------


To use:

`basename $0` <grp> <rat> <day>


This script wraps the MRDS functions by Ricardo Coronado.To cite:
Coronado-Leija, Ricardo, Alonso Ramirez-Manzanares, and Jose Luis Marroquin. 
  Estimation of individual axon bundle properties by a Multi-Resolution Discrete-Search method.
  Medical Image Analysis 42 (2017): 26-43.
  doi.org/10.1016/j.media.2017.06.008



LU15 (0N(H4
INB UNAM
March 2022
lconcha@unam.mx
  "
}


if [ $# -lt 3 ]
then
  echolor red "Not enough arguments"
	help
  exit 2
fi

grp=$1
rat=$2
day=$3




echolor yellow "[INFO] Starting to work"
date
hostname

ratdir=${imagesdir}/${grp}/${rat}/${day}
dwi_full=${ratdir}/dwi/dwi_hibval_deb.nii.gz
bvec_full=${dwi_full%.nii.gz}.bvec
bval_full=${dwi_full%.nii.gz}.bval


#dwi_full=${dwi_folder}/${grp}/${rat}/${day}/${rat}_${day}_${grp}_hibval_de.nii.gz
#bvec_full=${dwi_full%.nii.gz}.bvec
#bval_full=${dwi_full%.nii.gz}.bval
slicesfile=${ratdir}/derivatives/dwi/selected_slices
corticalmask=${ratdir}/derivatives/dwi/corticalmask.nii.gz 
outbase=${ratdir}/derivatives/dwi/dwi

isOK=1
for f in $dwi_full $bvec_full $bval_full $slicesfile $corticalmask
do
  if [ ! -f $f ]; then isOK=0; echolor red "[ERROR] Did not find $f";continue;fi
  echolor yellow "[INFO] Found $f"
done

if [ $isOK -eq 0 ]; then exit 2; fi


tmpDir=`mktemp -d`


cat $bvec_full $bval_full > ${tmpDir}/bvalbvec
transpose_table.sh ${tmpDir}/bvalbvec > ${tmpDir}/schemeorig
awk '{printf "%.5f %.5f %.5f %.4f\n", $1,$2,$3,$4}' ${tmpDir}/schemeorig > ${tmpDir}/scheme
scheme=${tmpDir}/scheme


shells=`mrinfo -quiet -bvalue_scaling false -grad $scheme $dwi_full -shell_bvalues`
firstbval=`echo $shells | awk '{print $1}'`
if (( $(echo "$firstbval > 0 " | bc -l)  ))
then
  echolor orange "[WARNING] Lowest bvalue is not zero, but $firstbval .  Will change to zero. "
  sed -i -e "s/${firstbval}/0.0000/g" $scheme
fi


echolor yellow "[INFO] Creating a generous mask from which we can estimate response."
fullmask=${tmpDir}/fullmask.nii
my_do_cmd dwi2mask -quiet -grad $scheme $dwi_full $fullmask


echolor yellow "[INFO] Estimating tensors fromt he whole brain."
my_do_cmd dti \
  -mask $fullmask \
  -response 0 \
  -correction 0 \
  -fa -md \
  $dwi_full \
  $scheme \
  ${outbase}


nAnisoVoxels=`fslstats ${outbase}_DTInolin_ResponseAnisotropicMask.nii -V | awk '{print $1}'`
if [ $nAnisoVoxels -lt 1 ]
then
  echolor red "[ERROR] Not enough anisotropic voxels found for estimation of response. Found $nAnisoVoxels"
fi
echolor yellow "Getting lambdas for response (from $nAnisoVoxels voxels)"
response=`cat ${outbase}_DTInolin_ResponseAnisotropic.txt | awk '{OFS = "," ;print $1,$2}'`
echolor yellow "  $response"



nSlices=$(cat $slicesfile | tr ' ' '\n' | wc -l)
for s in $(cat $slicesfile)
do
  echolor cyan "[INFO] Working on slice $s of $nSlices"
  dwi=${ratdir}/derivatives/dwi/slice_${s}/dwi.nii.gz
  bvec=${dwi%.nii.gz}.bvec
  bval=${dwi%.nii.gz}.bval
  

  isOK=1
  for f in $dwi $bvec $bval
  do
    if [ ! -f $f ]; then isOK=0; echolor red "[ERROR] Did not find $f";continue;fi
    echolor yellow "[INFO] Found $f"
  done
  if [ $isOK -eq 0 ]; then exit 2; fi

  mrinfo -force -quiet \
    -bvalue_scaling false \
    -fslgrad $bvec $bval $dwi  \
    -export_grad_mrtrix ${tmpDir}/schemeorig
  sed -i '/^#/d' ${tmpDir}/schemeorig
  awk '{printf "%.5f %.5f %.5f %.4f\n", $1,$2,$3,$4}' ${tmpDir}/schemeorig > ${tmpDir}/scheme
  scheme=${tmpDir}/scheme
  shells=`mrinfo -force -quiet -bvalue_scaling false -grad $scheme $dwi -shell_bvalues`
  firstbval=`echo $shells | awk '{print $1}'`
    echolor cyan "First bval is $firstbval"
  if (( $(echo "$firstbval > 0 " | bc -l)  ))
  then
    echolor orange "[WARNING] Lowest bvalue is not zero, but $firstbval .  Will change to zero. "
    sed -i -e "s/${firstbval}/0.0000/g" $scheme
  fi

  echolor yellow "[INFO] Restricting cortical mask to the slice we are working on."
  mask=${tmpDir}/corticalmask_slice_${s}.nii
  mrmath -axis 3 $dwi mean - | mrcalc - 0 -gt $corticalmask -mul $mask

  time my_do_cmd mdtmrds \
    $dwi \
    $scheme \
    ${outbase}_slice_${s} \
    -correction 0 \
    -response $response \
    -mask $mask \
    -modsel bic \
    -each \
    -intermediate \
    -fa -md -mse \
    -method diff 1
done

echolor yellow "[INFO] Concatenating the results from the different slices."
# create a blank file
mrcalc $corticalmask 0 -mul ${tmpDir}/blank.nii
s=$(awk '{print $1}' $slicesfile )
for f in ${outbase}_slice_${s}_MRDS_*.nii
do
  ff=${f#*_MRDS}
  #ls ${outbase}_slice_*_MRDS${ff}
  # what we need to do is add them up to a blank file.
  nFilesToAdd=$(ls ${outbase}_slice_*_MRDS${ff} | wc -l)
  filesToAdd=$(ls ${outbase}_slice_*_MRDS${ff})
  echo $nFilesToAdd $ff
  nAdd=""
  for i in $(seq 2 $nFilesToAdd)
  do
    nAdd="$nAdd -add"
  done
  mrcalc $blank ${filesToAdd} $nAdd ${outbase}_MRDS${ff}.gz
  rm $filesToAdd
done

gzip ${outbase}_*.nii



ls $tmpDir

rm -fR $tmpDir
