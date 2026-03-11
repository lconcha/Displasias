#!/bin/bash


# PURAS PENDEJADAS


for tck in /misc/sherrington2/Olimpia/proyecto/qti/R*/R*/fa_masks/sampled/out_r.tck
do
  mom=$(echo $tck | cut -d'/' -f7)
  rat=$(echo $tck | cut -d'/' -f8)
  echo $mom $rat
  uFA=/misc/sherrington2/Olimpia/proyecto/qti+/$mom/$rat/qtiplus_uFA.nii.gz
  tckmap -template $uFA $tck /tmp/qti/${rat}_map.nii
done