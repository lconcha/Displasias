#!/bin/bash
source `which my_do_cmd`
fakeflag=""


ratdir=$1

dwi=${ratdir}/dwi/dwi_hibval_deb.nii.gz
bvec=${dwi%.nii.gz}.bvec
bval=${dwi%.nii.gz}.bval
selected_slices=${ratdir}/derivatives/dwi/selected_slices
lines=${ratdir}/dwi/lines.nii.gz
outliermap=${ratdir}/derivatives/dwi/eddy_outlier_map
outlierreport=${ratdir}/derivatives/dwi/eddy_outlier_report

isOK=1
for f in $dwi $bvec $bval $selected_slices $lines $outliermap $outlierreport
do
  if [ ! -f $f ]
  then
     echolor red "[ERROR] Cannot find $f"
     isOK=0
  else
     echolor green "[INFO] Found $f"
  fi
done

if [ $isOK -eq 0 ]
then
  echolor red "[ERROR] Cannot continue"
  exit 2
fi


nVolsIN=`mrinfo -size $dwi | awk '{print $4}'`
echo "  Input file has $nVolsIN volumes"




tmpDir=$(mktemp -d)

my_do_cmd $fakeflag mrconvert -coord 3 0 -axes 0,1,2 $dwi ${tmpDir}/firstvol.nii
my_do_cmd $fakeflag mrcalc ${tmpDir}/firstvol.nii 0 -mul ${tmpDir}/zeros.nii
mrinfo ${tmpDir}/firstvol.nii
mrinfo ${tmpDir}/zeros.nii

slices=$(cat $selected_slices)
for s in $slices
do
  badvolslist=$(grep "Slice $s" $outlierreport | awk '{ORS=" "; print $5}')
  echolor yellow "[INFO] Found outliers for slice $s in volumes: $badvolslist"
  
  vol_indices=(`seq -s" " 0 $(($nVolsIN-1))`)
  ## Remove array elements
  for idx in $badvolslist
    do
      unset vol_indices[$idx]
  done
  indices=`echo ${vol_indices[@]} | tr " " ,`
  
  my_do_cmd $fakeflag mkdir -p ${ratdir}/derivatives/dwi/slice_${s}

  dwislice=${ratdir}/derivatives/dwi/slice_${s}/dwi.nii.gz
  bvecslice=${dwislice%.nii.gz}.bvec
  bvalslice=${dwislice%.nii.gz}.bval
  my_do_cmd $fakeflag mrconvert -quiet -force \
    -coord 3 $indices \
    -fslgrad $bvec $bval \
    -export_grad_fsl ${tmpDir}/bvecslice ${tmpDir}/bvalslice \
    $dwi \
    ${tmpDir}/dwislice.nii
  my_do_cmd $fakeflag mredit -quiet -force \
    -plane 1 $s 1 \
    ${tmpDir}/zeros.nii \
    ${tmpDir}/thisslice.nii
  my_do_cmd $fakeflag mrcalc -quiet \
    ${tmpDir}/thisslice.nii \
    ${tmpDir}/dwislice.nii \
    -mul \
    $dwislice
  my_do_cmd $fakeflag cp ${tmpDir}/bvecslice $bvecslice
  my_do_cmd $fakeflag cp ${tmpDir}/bvalslice $bvalslice
done


rm -fR $tmpDir