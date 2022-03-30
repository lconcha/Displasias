#!/bin/bash
source `which my_do_cmd`


multiline_volume=$1
outfolder=$2


my_do_cmd mrcalc -quiet $multiline_volume 1 -eq ${outfolder}/l_outline.nii.gz
my_do_cmd mrcalc -quiet $multiline_volume 2 -eq ${outfolder}/r_outline.nii.gz
my_do_cmd mrcalc -quiet $multiline_volume 3 -eq ${outfolder}/l_inline.nii.gz
my_do_cmd mrcalc -quiet $multiline_volume 4 -eq ${outfolder}/r_inline.nii.gz
