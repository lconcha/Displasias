#!/bin/bash
source `which my_do_cmd`
fakeflag=""

shareDir=/misc/nyquist/lconcha/nobackup/data_share_displasia
rat_table=${shareDir}/rat_table.csv
gridDir=/misc/nyquist/dcortes_aylin/displaciasCorticales/derivatives
rawDir=/misc/nyquist/dcortes_aylin/displaciasCorticales/raw
preprocDir=/misc/nyquist/dcortes_aylin/displaciasCorticales/preproc

#grid: */*/minc/*_l_grid_mid.nii*
#raw: */*/dwi/*clean*
#preproc: */*/*/*_den_unr_ec_ub_clean.nii
#b:  */*/*/*clean.b


tail -n +2 $rat_table | while read line
do
  rat=$(echo $line | awk -F, '{print $1}')
  echolor cyan $rat
  raw=${rawDir}/${rat}/ses-P30/dwi/${rat}_raw_clean.mif
  preproc=${preprocDir}/${rat}/ses-P30/dwi/${rat}_den_unr_ec_ub_clean.nii
  b=${preprocDir}/${rat}/ses-P30/dwi/grad_raw_0s_clean.b
  grid=${gridDir}/${rat}/ses-P30/minc/${rat}_l_grid_mid.nii.gz
  tck=$(ls ${gridDir}/${rat}/ses-P30/minc/tck/${rat}_l_*_resampled.tck)


  isOK=1
  for f in $raw $preproc $b $grid $tck
  do
    if [ ! -f $f ]
    then
       isOK=0
       echolor orange "[ERROR] File not found: $f"
    else
       echolor yellow "  [OK] $f" 
    fi
  done

  if [ $isOK -eq 1 ]
  then
    my_do_cmd $fakeflag mkdir ${shareDir}/${rat}
    my_do_cmd $fakeflag cp $raw ${shareDir}/${rat}/dwi_raw.mif
    my_do_cmd $fakeflag mrconvert -grad $b $preproc ${shareDir}/${rat}/dwi_preproc.mif
    my_do_cmd $fakeflag mrconvert $grid ${shareDir}/${rat}/cortex_mask.mif
    #my_do_cmd $fakeflag cp $tck ${shareDir}/${rat}/streamlines.tck
  fi

done