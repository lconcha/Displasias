#!/bin/bash
source `which my_do_cmd`

help(){
  echo "


Fit multi-tensors using multi-resolution discrete search (MRDS) within a mask.

-------------------
NOTE:
This script is designed to work on a slice-by-slice fashion, within a pre-defined
folder structure that separates each slice and eliminates signal outliers.
-------------------


Please allow around one hour per slice analyzed.

Uses multi-threading, avoid running multiple jobs at the same time.


How to use:
  `basename $0` <dwi_folder> <outbase>


Note:    MRDS cannot handle DWI data sets without b=0 volumes. 
         The Bruker scanner provides bvals that include diffusion gradient sensitization
         from all gradients, including the spatial encoding gradients and crushers, and
         therefore there are no b=0 bvals, but rather a very small b value (e.g b=28 s/mm2).
         This script will automatically find the lowest bvalue and turn it to zero.


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


if [ $# -lt 6 ]
then
  echolor red "Not enough arguments"
	help
  exit 2
fi




dwi_folder=$1
corticalmask_folder=$2
grp=$3
rat=$4
day=$5
outbase=$6

dwi_full=${dwi_folder}/${grp}/${rat}/${day}/${rat}_${day}_${grp}_hibval_de.nii.gz
bvec_full=${dwi_full%.nii.gz}.bvec
bval_full=${dwi_full%.nii.gz}.bval
slicesfile=${dwi_folder}/${grp}/${rat}/${day}/${rat}_${day}.selected_slices

isOK=1
for f in $dwi_full $bvec_full $bval_full $slicesfile
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




for s in $(cat $slicesfile)
do
  echolor cyan "[INFO] Working on slice $s"
  dwi=${dwi_folder}/${grp}/${rat}/${day}/slice_${s}/${rat}_${day}_${grp}_hibval_deb.nii.gz
  bvec=${dwi%.nii.gz}.bvec
  bval=${dwi%.nii.gz}.bval
  corticalmask=${corticalmask_folder}/${rat}_${day}_${grp}_corticalmask.nii.gz

  isOK=1
  for f in $dwi $bvec $bval $corticalmask
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

ls $tmpDir

rm -fR $tmpDir