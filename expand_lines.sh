#!/bin/bash
source `which my_do_cmd`


multiline_volume=$1
rat=$2
outfolder=$3


my_do_cmd mrcalc -quiet $multiline_volume 1 -eq ${outfolder}/${rat}_l_outline.nii.gz
my_do_cmd mrcalc -quiet $multiline_volume 2 -eq ${outfolder}/${rat}_r_outline.nii.gz
my_do_cmd mrcalc -quiet $multiline_volume 3 -eq ${outfolder}/${rat}_l_inline.nii.gz
my_do_cmd mrcalc -quiet $multiline_volume 4 -eq ${outfolder}/${rat}_r_inline.nii.gz