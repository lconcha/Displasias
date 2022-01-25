#!/bin/bash
source `which my_do_cmd`

lines=$1
rat=$2
outfolder=$3
slice=$4


tmpDir=`mktemp -d`

plines=${outfolder}/lines.nii.gz


size1=$(mrinfo -size $lines | awk '{print $1}')
size2=$(mrinfo -size $lines | awk '{print $2}')
size3=$(mrinfo -size $lines | awk '{print $3}')


echolor yellow "sizes: $size1 $size2 $size3"
if [ $size2 -lt $size3 ]
then
  echolor cyan "Warning: size2 is larger than size3"
  my_do_cmd mrconvert -axes 0,2,1 \
            -strides 1,2,3 \
            $lines \
            ${tmpDir}/plines.nii.gz
        
else
  cp $lines ${tmpDir}/plines.nii.gz
fi


my_do_cmd mrcalc ${tmpDir}/plines.nii.gz 0 -mul ${tmpDir}/plane.nii 
my_do_cmd mredit -plane 2 $slice 1 ${tmpDir}/plane.nii
my_do_cmd mrcalc ${tmpDir}/plane.nii ${tmpDir}/plines.nii.gz -mul ${tmpDir}/plines_one.nii.gz


my_do_cmd expand_lines.sh ${tmpDir}/plines_one.nii.gz $rat $outfolder


echolor cyan "Try running, for example:
 nii2streams.sh ${outfolder}/${rat}_l_inline.nii.gz ${outfolder}/${rat}_l_outline.nii.gz ${outfolder}/${rat}_l_inline.nii.gz ${outfolder} l $rat"

rm -fR $tmpDir